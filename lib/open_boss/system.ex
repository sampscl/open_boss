defmodule OpenBoss.System do
  @moduledoc """
  System context
  """

  @callback reboot() :: :ok
  defdelegate reboot,
    to: Application.compile_env!(:open_boss, [__MODULE__, :implementation])
end
