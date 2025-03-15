defmodule OpenBoss.Rpi4Kiosk.Boot do
  @moduledoc """
  Boot implementation
  """

  alias OpenBoss.Boot
  alias OpenBoss.Repo
  alias OpenBoss.Displays
  alias OpenBoss.Displays.Display

  require Logger

  @behaviour Boot

  @impl Boot
  def handle_action(:reconcile_displays) do
    Task.Supervisor.async_nolink(OpenBoss.TaskSupervisor, fn ->
      # give the display(s) time to initialize
      Process.sleep(:timer.seconds(10))

      present = Path.wildcard("/sys/class/backlight/*")
      all_displays = Repo.all(Display)
      all_paths = Enum.map(all_displays, & &1.path)

      # delete missing, apply settings if present
      Enum.each(all_displays, fn display ->
        if display.path not in present do
          Logger.info("Removing absent display #{display.path}")
          _ = Repo.delete(display)
        else
          Logger.info("Applying settings for existing display #{display.path}")
          :ok = Displays.apply_settings(display)
        end
      end)

      # create new for present but not in db
      Enum.each(present -- all_paths, fn new ->
        brightness =
          File.read!("#{new}/actual_brightness")
          |> String.trim()
          |> String.to_integer()
          |> Kernel.*(100)
          |> Kernel./(255)
          |> trunc()

        Logger.info("New display #{new}")
        {:ok, _} = Displays.create_display(%{path: new, brightness: brightness})
      end)
    end)

    :ok
  end
end
