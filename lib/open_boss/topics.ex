defmodule OpenBoss.Topics do
  @moduledoc """
  Pub/sub topics for easy and consistent reference
  """

  @doc """
  Device presence channel

  Device presence:
  - `{:worker_start, %OpenBoss.Devices.Device{}}`
  - `{:worker_lost, %OpenBoss.Devices.Device{}}`
  """
  @spec device_presence() :: String.t()
  def device_presence, do: "device-presence"

  @doc """
  Device state channel

  Devices state:
  - `{:device_state, %OpenBoss.Devices.Device{}}`
  """
  @spec device_state(integer()) :: String.t()
  def device_state(device_id), do: "device-state-#{device_id}"
end
