defmodule OpenBoss.Target.System do
  @moduledoc """
  Target implementation
  """

  alias OpenBoss.System
  @behaviour System

  @impl System
  def reboot do
    _ = Nerves.Runtime.reboot()
    :ok
  end
end
