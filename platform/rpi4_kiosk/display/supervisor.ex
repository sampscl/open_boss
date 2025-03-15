defmodule OpenBoss.Rpi4Kiosk.Display.Supervisor do
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
      {OpenBoss.Rpi4Kiosk.Display.UdevdServer, []},
      {OpenBoss.Rpi4Kiosk.Display.WaylandApps.Supervisor, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
