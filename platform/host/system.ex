defmodule OpenBoss.Host.System do
  @moduledoc """
  Host implementation
  """

  alias OpenBoss.System
  @behaviour System

  @impl System
  def reboot, do: {:error, "Reboot not supported on the host"}
end
