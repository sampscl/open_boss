defmodule OpenBoss.Boot do
  @moduledoc """
  Perform boot-time work
  """
  use GenServer

  @callback handle_action(:reconcile_displays) :: :ok
  defdelegate handle_action(action),
    to: Application.compile_env!(:open_boss, [__MODULE__, :implementation])

  @spec child_spec(term) :: Supervisor.child_spec()

  def child_spec(action) do
    %{
      id: action,
      start: {__MODULE__, :start_link, [action]}
    }
  end

  @spec start_link(term) :: GenServer.on_start()
  def start_link(action) do
    GenServer.start_link(__MODULE__, action)
  end

  @impl GenServer
  def init(action) do
    handle_action(action)
    :ignore
  end
end
