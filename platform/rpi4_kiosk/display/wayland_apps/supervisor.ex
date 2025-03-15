defmodule OpenBoss.Rpi4Kiosk.Display.WaylandApps.Supervisor do
  @moduledoc """
  Supervisor for the display pids
  """

  use Supervisor

  @spec start_link(keyword()) :: Supervisor.on_start()
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl Supervisor
  def init(_args) do
    children = [
      {OpenBoss.Rpi4Kiosk.Display.WaylandApps.WestonServer, []},
      {OpenBoss.Rpi4Kiosk.Display.WaylandApps.CogServer, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
