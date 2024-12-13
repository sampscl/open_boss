defmodule OpenBossWeb.DevicesLive.DeviceIdNotFoundError do
  defexception message: "invalid device id", plug_status: 404
end
