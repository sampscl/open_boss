defmodule OpenBoss.Target.Displays do
  @moduledoc """
  Target implementation
  """

  alias OpenBoss.Displays

  @behaviour Displays

  @impl Displays
  def apply_settings(_display) do
    {:error, "display updates not supported on this target"}
  end
end
