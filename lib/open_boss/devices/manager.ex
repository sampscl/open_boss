defmodule OpenBoss.Devices.Manager do
  @moduledoc """
  Management genserver for devices
  """

  require Logger

  use GenServer, restart: :transient

  alias OpenBoss.Devices
  alias OpenBoss.Devices.Payload

  @spec start_link(any) :: GenServer.on_start()
  def start_link(params), do: GenServer.start_link(__MODULE__, params, name: __MODULE__)

  @spec list() :: list(Devices.device_state())
  def list, do: GenServer.call(__MODULE__, :list)

  @spec ensure_managed(Devices.init_param()) :: :ok
  def ensure_managed(device), do: GenServer.cast(__MODULE__, {:ensure_managed, device})

  @spec device_state(device_id :: non_neg_integer()) ::
          {:ok, Devices.device_state()} | {:error, :not_found}
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
      :devices,
      :mqtt_pids
    ]

    @type t() :: %__MODULE__{
            devices: %{
              Devices.id() => Devices.device_state()
            },
            mqtt_pids: %{pid() => Devices.id()}
          }
  end

  @impl GenServer
  def init(_) do
    Logger.info("Starting")
    send(self(), :ping)
    {:ok, %State{devices: %{}, mqtt_pids: %{}}}
  end

  @impl GenServer
  def handle_call({:device_state, device_id}, _from, %{devices: devices} = state) do
    if device = Map.get(devices, device_id) do
      {:reply, {:ok, device}, state}
    else
      {:reply, {:error, :not_found}, state}
    end
  end

  @impl GenServer
  def handle_call(:list, _from, %{devices: devices} = state) do
    result = Enum.map(devices, fn {_, device_state} -> device_state end)
    {:reply, result, state}
  end

  @impl GenServer
  def handle_call({:set_temp, device_id, celsius}, _from, %{devices: devices} = state) do
    device = Map.get(devices, device_id)

    {result, new_device_state} =
      case :emqtt.publish(
             device.mqtt_pid(),
             "flameboss/#{device_id}/recv",
             Jason.encode!(%{
               "name" => "set_temp",
               "value" => Payload.encode_temp(celsius)
             })
           ) do
        :ok ->
          new_state = %{device | requested_temp: celsius}
          :ok = pub_device_state!(new_state)
          {:ok, new_state}

        {:ok, reply} ->
          Logger.debug("Unexpected reply on set_temp: #{inspect(reply)}")
          new_state = %{device | requested_temp: celsius}
          :ok = pub_device_state!(new_state)
          {:ok, new_state}

        err ->
          {err, device}
      end

    {:reply, result, %{state | devices: Map.put(devices, device_id, new_device_state)}}
  end

  @impl GenServer
  def handle_cast(
        {:ensure_managed, %{domain: domain, ip: ip, port: port, services: services}},
        %{devices: devices, mqtt_pids: mqtt_pids} = state
      ) do
    device_id = domain_to_device_id(domain)

    if _existing = Map.get(devices, device_id) do
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

      device_state = %{
        ip: ip,
        port: port,
        services: services,
        domain: domain,
        client_id: client_id,
        mqtt_pid: mqtt_pid,
        device_id: device_id,
        requested_temp: nil,
        set_temp: nil,
        temps: %{pit_1: nil, meat_1: nil, pit_2: nil, meat_2: nil},
        blower: nil,
        protocol: nil,
        id_message: nil,
        set_temp_limits: nil,
        ntp: nil,
        versions: nil,
        last_update: nil
      }

      updated_state = %{
        state
        | devices: Map.put(devices, device_id, device_state),
          mqtt_pids: Map.put(mqtt_pids, mqtt_pid, device_id)
      }

      :ok =
        Phoenix.PubSub.broadcast(
          OpenBoss.PubSub,
          "device-presence",
          {:worker_start, device_state}
        )

      {:noreply, updated_state}
    end
  end

  @impl GenServer
  def handle_info(:ping, %{mqtt_pids: mqtt_pids} = state) do
    _ = Process.send_after(self(), :ping, :timer.minutes(1))

    Enum.each(Map.keys(mqtt_pids), fn pid ->
      Task.Supervisor.start_child(OpenBoss.TaskSupervisor, fn ->
        ping(pid)
      end)
    end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(
        {:DOWN, _ref, :process, pid, reason},
        %{devices: devices, mqtt_pids: mqtt_pids} = state
      ) do
    maybe_device_id = Map.get(mqtt_pids, pid)

    if device = Map.get(devices, maybe_device_id) do
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
         | devices: Map.delete(devices, maybe_device_id),
           mqtt_pids: Map.delete(mqtt_pids, pid)
       }}
    else
      Logger.warning("Unknown device #{inspect({pid, reason})}")
      {:noreply, state}
    end
  end

  @impl GenServer
  def handle_info(
        {:publish, %{client_pid: mqtt_pid, payload: payload}} = msg,
        %{devices: devices, mqtt_pids: mqtt_pids} = state
      ) do
    maybe_device_id = Map.get(mqtt_pids, mqtt_pid)

    if device = Map.get(devices, maybe_device_id) do
      updated_device = Payload.handle_payload(device, payload)
      :ok = pub_device_state!(updated_device)
      {:noreply, %{state | devices: Map.put(devices, maybe_device_id, updated_device)}}
    else
      Logger.warning("Got message for unknown pid: #{inspect(msg)}")
      {:noreply, state}
    end
  end

  @spec pub_device_state!(Devices.device_state()) :: :ok
  defp pub_device_state!(%{device_id: device_id} = state) do
    :ok =
      Phoenix.PubSub.broadcast!(
        OpenBoss.PubSub,
        "device-state-#{device_id}",
        {:device_state, state}
      )
  end

  @spec domain_to_device_id(String.t()) :: integer()
  defp domain_to_device_id("fb-" <> id_and_suffix = _domain) do
    String.split(id_and_suffix, ".", parts: 2)
    |> List.first()
    |> String.to_integer()
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
end
