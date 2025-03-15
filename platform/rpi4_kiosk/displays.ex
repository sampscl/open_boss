defmodule OpenBoss.Rpi4Kiosk.Displays do
  @moduledoc """
  pi4 kiosk implementation
  """

  alias OpenBoss.Displays

  @behaviour Displays

  @impl Displays
  def apply_settings(%{path: path, brightness: brightness}) do
    scaled = trunc(brightness * 256 / 100)
    File.write!("#{path}/brightness", "#{scaled}")
  end
end
