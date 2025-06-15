defmodule OpenBoss.Host.System do
  @moduledoc """
  Host implementation
  """

  alias OpenBoss.System
  @behaviour System

  @impl System
  def reboot do
    raise "Reboot not implemented on host platform"
  end
end
