defmodule OpenBoss.Target.Boot do
  @moduledoc """
  Boot implementation
  """

  alias OpenBoss.Boot
  alias OpenBoss.Repo
  alias OpenBoss.Displays.Display

  @behaviour Boot

  @impl Boot
  def handle_action(:reconcile_displays) do
    # generic target does not deal with displays
    _ = Repo.delete_all(Display)
    :ok
  end
end
