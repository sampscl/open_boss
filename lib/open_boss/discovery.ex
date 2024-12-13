defmodule OpenBoss.Discovery do
  @moduledoc """
  Discover supported devices. Will publish when they are discovered
  """
  alias OpenBoss.Devices.Manager

  require Logger

  use GenServer, restart: :transient

  defmodule State do
    @moduledoc false
    defstruct [
      :interval,
      :count
    ]

    @type device :: %Mdns.Client.Device{}
    @type t() :: %__MODULE__{
            interval: pos_integer(),
            count: pos_integer() | :inifinite
          }
  end

  @spec start_link(list) :: GenServer.on_start()
  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  @impl GenServer
  def init(_) do
    Logger.info("Starting discovery")

    send(self(), :discover)

    # # Delay sending new devices so they have time to respond; this
    # # shortens the delay at startup before existing devices are
    # # available in the app
    # Process.send_after(self(), :handle_new_devices, :timer.seconds(2))

    state = %State{
      interval: :timer.seconds(5),
      count: 3
    }

    {:ok, state, {:continue, :start_mdns}}
  end

  @impl GenServer
  def handle_continue(:start_mdns, state) do
    Logger.info("Starting MDNS client")
    :ok = Mdns.Client.start()
    :ok = Mdns.EventManager.add_handler()
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:discover, state) do
    next_state = next_interval_and_count(state)
    Process.send_after(self(), :discover, next_state.interval)
    :ok = Mdns.Client.query("_flameboss._tcp.local")
    {:noreply, next_state}
  end

  @impl GenServer
  def handle_info(
        {:"_flameboss._tcp.local", %Mdns.Client.Device{} = device},
        state
      ) do
    :ok = Manager.ensure_managed(Map.take(device, [:ip, :port, :services, :domain]))
    {:noreply, state}
  end

  @spec next_interval_and_count(State.t()) :: State.t()
  defp next_interval_and_count(%{count: :infinite} = state), do: state

  defp next_interval_and_count(%{count: count} = state) when count == 0,
    do: %{state | interval: :timer.seconds(60), count: :infinite}

  defp next_interval_and_count(%{count: count} = state),
    do: %{state | count: count - 1}
end
