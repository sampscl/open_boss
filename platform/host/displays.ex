defmodule OpenBoss.Host.Displays do
  @moduledoc """
  Host implementation
  """

  alias OpenBoss.Displays

  @behaviour Displays

  @impl Displays
  def apply_settings(_display) do
    {:error, "display updates not supported on the host"}
  end
end
