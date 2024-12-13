defmodule OpenBoss.Devices.Payload do
  @moduledoc """
  Functions that handle incoming device payloads. Located here
  to simplify the device manager a bit.
  """

  require Logger

  alias OpenBoss.Devices.Device

  @spec decode_temp(raw :: integer()) :: celsius :: float() | nil
  def decode_temp(-32_767), do: nil
  def decode_temp(raw), do: raw / 10.0

  @spec decode_percent(raw :: integer()) :: float()
  def decode_percent(raw), do: raw / 100.0

  @spec encode_temp(celsius :: float()) :: raw :: integer()
  def encode_temp(celsius), do: round(celsius * 10.0)

  @spec handle_payload(Device.t(), json :: String.t()) :: Ecto.Changeset.t(Device.t())
  def handle_payload(device, payload) do
    update_state(device, Jason.decode(payload))
  end

  @spec update_state(Device.t(), {:ok, map()} | {:error, any()}) ::
          Ecto.Changeset.t(Device.t())

  defp update_state(device, {:ok, %{"name" => "id", "device_id" => _id}}) do
    # This is just the device reporting it's ID, which we have gotten
    # from the mDNS network traffic and potentially other messages
    Device.changeset(device, %{})
  end

  defp update_state(
         device,
         {:ok,
          %{
            "name" => "temps",
            "temps" => [pit_1, meat_1, pit_2, meat_2],
            "set_temp" => set_temp,
            "blower" => blower
          }}
       ) do
    Device.changeset(device, %{
      set_temp: decode_temp(set_temp),
      blower: decode_percent(blower),
      temps: %{
        pit_1: decode_temp(pit_1),
        meat_1: decode_temp(meat_1),
        pit_2: decode_temp(pit_2),
        meat_2: decode_temp(meat_2)
      }
    })
  end

  defp update_state(device, {:ok, %{"name" => "set_temp", "value" => set_temp}}) do
    Device.changeset(device, %{set_temp: decode_temp(set_temp)})
  end

  defp update_state(device, {:ok, %{"name" => "protocol", "version" => version}}) do
    Device.changeset(device, %{protocol_version: version})
  end

  defp update_state(
         device,
         {:ok,
          %{
            "name" => "id",
            "device_id" => device_id,
            "uid" => uid,
            "pin" => pin,
            "disabled" => disabled
          }}
       ) do
    Device.changeset(device, %{
      device_id: device_id,
      pin: pin,
      disabled: disabled,
      uid: Base.decode64(uid)
    })
  end

  defp update_state(device, {:ok, %{"name" => "set_temp_limits", "min" => min, "max" => max}}) do
    Device.changeset(device, %{
      min_temp: decode_temp(min),
      max_temp: decode_temp(max)
    })
  end

  defp update_state(device, {:ok, %{"name" => "ntp", "host" => host}}) do
    Device.changeset(device, %{ntp_host: host})
  end

  defp update_state(
         device,
         {:ok,
          %{
            "name" => "versions",
            "app" => app,
            "boot" => boot,
            "bt" => bt,
            "hw_id" => hw_id,
            "next_addr" => next_addr,
            "pos" => pos,
            "revert_avail" => revert_avail,
            "wifi" => wifi
          }}
       ) do
    Device.changeset(device, %{
      app_version: app,
      boot_version: boot,
      bt_version: bt,
      hw_id_version: hw_id,
      next_addr_version: next_addr,
      pos_version: pos,
      revert_avail_version: revert_avail,
      wifi_version: wifi
    })
  end

  defp update_state(device, {:ok, unhandled}) do
    Logger.debug("Unhandled: #{inspect({device.id, unhandled})}")
    Device.changeset(device, %{})
  end

  defp update_state(device, {:error, err}) do
    Logger.error("Payload decode error: #{err}")
    Device.changeset(device, %{})
  end
end
