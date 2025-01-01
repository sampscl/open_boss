defmodule OpenBoss.Devices.Manager do
  @moduledoc """
  Management genserver for devices
  """

  require Logger

  use GenServer, restart: :transient

  import Ecto.Query

  alias OpenBoss.ActiveCooks
  alias OpenBoss.Devices
  alias OpenBoss.Devices.Device
  alias OpenBoss.Devices.Payload
  alias OpenBoss.Repo

  @type init_param() :: %{
          ip: :inet.socket_address(),
          port: non_neg_integer(),
          services: list(String.t()),
          domain: String.t()
        }

  @spec start_link(any) :: GenServer.on_start()
  def start_link(params), do: GenServer.start_link(__MODULE__, params, name: __MODULE__)

  @spec list() :: list(Device.t())
  def list, do: GenServer.call(__MODULE__, :list)

  @spec ensure_managed(init_param()) :: :ok
  def ensure_managed(param), do: GenServer.cast(__MODULE__, {:ensure_managed, param})

  @spec device_state(device_id :: non_neg_integer()) ::
          {:ok, Device.t()} | {:error, :not_found}
  def device_state(device_id), do: GenServer.call(__MODULE__, {:device_state, device_id})

  @spec set_temp(
          device_id :: non_neg_integer(),
          temp :: float(),
          unit :: :farenheit | :celsius
        ) ::
          :ok | {:error, :not_found} | {:error, any()}
  def set_temp(device_id, temp, unit)

  def set_temp(device_id, farenheit, :farenheit),
    do: set_temp(device_id, OpenBoss.Utils.farenheit_to_celsius(farenheit), :celsius)

  def set_temp(device_id, celsius, :celsius),
    do: GenServer.call(__MODULE__, {:set_temp, device_id, celsius})

  defmodule State do
    @moduledoc false

    alias OpenBoss.Devices

    defstruct [
      :mqtt_pids,
      :device_ids
    ]

    @type t() :: %__MODULE__{
            mqtt_pids: %{Devices.id() => pid()},
            device_ids: %{pid() => Devices.id()}
          }
  end

  @impl GenServer
  def init(_) do
    Logger.info("Starting")
    send(self(), :ping)
    {:ok, %State{mqtt_pids: %{}, device_ids: %{}}}
  end

  @impl GenServer
  def handle_call({:device_state, device_id}, _from, %{mqtt_pids: mqtt_pids} = state) do
    if Map.has_key?(mqtt_pids, device_id) do
      device = load_device(device_id)
      {:reply, {:ok, device}, state}
    else
      # do not give active device state for inactive devices
      {:reply, {:error, :not_found}, state}
    end
  end

  @impl GenServer
  def handle_call(:list, _from, %{mqtt_pids: mqtt_pids} = state) do
    result =
      from(d in Device,
        where: d.id in ^Map.keys(mqtt_pids)
      )
      |> Repo.all()

    {:reply, result, state}
  end

  @impl GenServer
  def handle_call(
        {:set_temp, device_id, celsius},
        _from,
        %{mqtt_pids: mqtt_pids} = state
      ) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:mqtt_pid, fn _repo, _changes ->
        case Map.get(mqtt_pids, device_id) do
          nil -> {:error, :not_found}
          pid -> {:ok, pid}
        end
      end)
      |> Ecto.Multi.run(:device, fn _repo, _changes ->
        if device = load_device(device_id) do
          {:ok, device}
        else
          {:error, :not_found}
        end
      end)
      |> Ecto.Multi.run(:mqtt_pub, fn _repo, %{mqtt_pid: mqtt_pid} ->
        # This is not very transactional: you cannot un-publish. The worst
        # that can happen is that subsequent steps fail but the device
        # sets the requested temperature. Eventually the MQTT will let
        # us know that the device set_temp has changed and the ui and
        # db will get updated.
        :emqtt.publish(
          mqtt_pid,
          "flameboss/#{device_id}/recv",
          Jason.encode!(%{
            "name" => "set_temp",
            "value" => Payload.encode_temp(celsius)
          })
        )
        |> case do
          {:error, _} = err ->
            err

          _ok ->
            {:ok, :ok}
        end
      end)
      |> Ecto.Multi.run(:update_device, fn _repo, %{device: device} ->
        Device.changeset(device, %{requested_temp: celsius}) |> Repo.update()
      end)
      |> Ecto.Multi.run(:pub, fn _repo, %{update_device: device} ->
        {:ok, pub_device_state!(device)}
      end)
      |> Repo.transaction()

    {:reply, result, state}
  end

  if Application.compile_env!(:open_boss, __MODULE__) |> Keyword.fetch!(:enable_mqtt) do
    @impl GenServer
    def handle_cast(msg, state) do
      start_mqtt(msg, state)
    end
  else
    @impl GenServer
    def handle_cast(_msg, state) do
      {:noreply, state}
    end
  end

  @impl GenServer
  def handle_info(:ping, %{mqtt_pids: mqtt_pids} = state) do
    _ = Process.send_after(self(), :ping, :timer.minutes(1))

    Enum.each(Map.values(mqtt_pids), fn pid ->
      Task.Supervisor.start_child(OpenBoss.TaskSupervisor, fn ->
        ping(pid)
      end)
    end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(
        {:DOWN, _ref, :process, pid, reason},
        %{mqtt_pids: mqtt_pids, device_ids: device_ids} = state
      ) do
    maybe_device_id =
      Enum.reduce_while(mqtt_pids, nil, fn {device_id, mqtt_pid}, _ ->
        if mqtt_pid == pid, do: {:halt, device_id}, else: {:cont, nil}
      end)

    if device = load_device(maybe_device_id) do
      Logger.info("Lost device #{inspect({pid, device, reason})}")

      :ok =
        Phoenix.PubSub.broadcast(
          OpenBoss.PubSub,
          "device-presence",
          {:worker_lost, device}
        )

      {:noreply,
       %{
         state
         | mqtt_pids: Map.delete(mqtt_pids, maybe_device_id),
           device_ids: Map.delete(device_ids, pid)
       }}
    else
      Logger.warning("Unknown device #{inspect({pid, reason})}")
      {:noreply, state}
    end
  end

  @impl GenServer
  def handle_info(
        {:publish, %{client_pid: mqtt_pid, payload: payload}} = msg,
        %{device_ids: device_ids} = state
      ) do
    maybe_device_id = Map.get(device_ids, mqtt_pid)

    if device = load_device(maybe_device_id) do
      {:ok, updated_device} =
        Payload.handle_payload(device, payload)
        |> Ecto.Changeset.change(%{last_communication: DateTime.utc_now()})
        |> Repo.update()

      _ = ActiveCooks.maybe_add_cook_history(updated_device)

      :ok = pub_device_state!(updated_device)
    else
      Logger.warning("Got message for unknown pid: #{inspect(msg)}")
    end

    {:noreply, state}
  end

  @spec pub_device_state!(Device.t()) :: :ok
  defp pub_device_state!(device) do
    :ok =
      Phoenix.PubSub.broadcast!(
        OpenBoss.PubSub,
        "device-state-#{device.id}",
        {:device_state, device}
      )

    :ok =
      Phoenix.PubSub.broadcast!(
        OpenBoss.PubSub,
        "device-state-all",
        {:device_state, device}
      )
  end

  # the erlang spec for :emqtt.ping/1 does not correctly
  # list the {:error, :ack_timeout} return, which
  # definitely happens in the real world so suppress
  # the resulting dialyzer warning :-/
  @dialyzer {:nowarn_function, ping: 1}
  @spec ping(pid) :: :pong | {:error, :ack_timeout}
  defp ping(pid) do
    case :emqtt.ping(pid) do
      :pong ->
        Logger.debug("Ping -> Pong for #{inspect(pid)}")
        :pong

      {:error, :ack_timeout} ->
        Logger.error("Ping timeout for #{inspect(pid)}")
        :emqtt.stop(pid)
        {:error, :ack_timeout}
    end
  end

  @spec load_device(integer() | nil) :: Device.t() | nil
  defp load_device(nil), do: nil
  defp load_device(device_id), do: Repo.get(Device, device_id)

  if Application.compile_env!(:open_boss, __MODULE__) |> Keyword.fetch!(:enable_mqtt) do
    @spec start_mqtt({:ensure_managed, map()}, State.t()) :: {:noreply, State.t()}
    defp start_mqtt(
           {:ensure_managed,
            %{domain: "fb-" <> id_and_suffix = domain, ip: ip, port: port, services: _services}},
           %{mqtt_pids: mqtt_pids, device_ids: device_ids} = state
         ) do
      device_id =
        String.split(id_and_suffix, ".", parts: 2)
        |> List.first()
        |> String.to_integer()

      if _existing = Map.get(mqtt_pids, device_id) do
        {:noreply, state}
      else
        Logger.info("Starting MQTT for #{domain}")

        ip_string = Tuple.to_list(ip) |> Enum.join(".")

        # Get /switch to switch to "Flame Boss Protocol"; not sure what
        # this is meant to do, but the iOS app does it and it seems
        # harmless not to mimic that behavior. Sometimes when the device
        # is working properly it does not return a HTTP/200 like it should,
        # so the http result is not verified. If there's a real problem it
        # will be detected below in the MQTT connection.
        http_result =
          :httpc.request(
            :get,
            {~c"http://#{ip_string}/switch", []},
            [timeout: :timer.seconds(1)],
            []
          )

        Logger.debug("GET /switch result: #{inspect(http_result, pretty: true)}")

        client_id = "open-boss-#{UUID.uuid4()}"

        Logger.debug("New client_id #{client_id}")

        {:ok, mqtt_pid} =
          :emqtt.start_link(
            host: ip_string |> to_charlist(),
            port: port,
            clientid: to_charlist(client_id)
          )

        _ = Process.monitor(mqtt_pid)
        _ = Process.unlink(mqtt_pid)

        {:ok, _} = :emqtt.connect(mqtt_pid)
        {:ok, _, _} = :emqtt.subscribe(mqtt_pid, "#")

        Logger.info("Connected (#{client_id})")

        {:ok, device} =
          (load_device(device_id) || %Device{id: device_id})
          |> Device.changeset(%{
            id: device_id,
            ip: ip_string,
            port: port,
            last_communication: DateTime.utc_now()
          })
          |> Repo.insert_or_update()

        :ok =
          Phoenix.PubSub.broadcast(
            OpenBoss.PubSub,
            "device-presence",
            {:worker_start, device}
          )

        updated_state = %{
          state
          | mqtt_pids: Map.put(mqtt_pids, device_id, mqtt_pid),
            device_ids: Map.put(device_ids, mqtt_pid, device_id)
        }

        {:noreply, updated_state}
      end
    end
  end
end
