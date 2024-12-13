defmodule OpenBoss.Devices.Payload do
  @moduledoc """
  Functions that handle incoming device payloads. Located here
  to simplify the device manager a bit.
  """

  require Logger

  alias OpenBoss.Devices

  @spec decode_temp(raw :: integer()) :: celsius :: float() | nil
  def decode_temp(-32_767), do: nil
  def decode_temp(raw), do: raw / 10.0

  @spec decode_percent(raw :: integer()) :: float()
  def decode_percent(raw), do: raw / 100.0

  @spec encode_temp(celsius :: float()) :: raw :: integer()
  def encode_temp(celsius), do: round(celsius * 10.0)

  @spec handle_payload(Devices.device_state(), json :: String.t()) :: Devices.device_state()
  def handle_payload(device, payload) do
    update_state(device, Jason.decode(payload)) |> Map.put(:last_update, DateTime.utc_now())
  end

  @spec update_state(Devices.device_state(), {:ok, map()} | {:error, any()}) ::
          Devices.device_state()

  defp update_state(device, {:ok, %{"name" => "id", "device_id" => _id}}) do
    # This is just the device reporting it's ID, which we have gotten
    # from the mDNS network traffic and potentially other messages
    device
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
    %{
      device
      | set_temp: decode_temp(set_temp),
        blower: decode_percent(blower),
        temps: %{
          pit_1: decode_temp(pit_1),
          meat_1: decode_temp(meat_1),
          pit_2: decode_temp(pit_2),
          meat_2: decode_temp(meat_2)
        }
    }
  end

  defp update_state(device, {:ok, %{"name" => "set_temp", "value" => set_temp}}) do
    %{device | set_temp: decode_temp(set_temp)}
  end

  defp update_state(device, {:ok, %{"name" => "protocol", "version" => version}}) do
    %{device | protocol: %{version: version}}
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
    %{
      device
      | id_message: %{
          device_id: device_id,
          pin: pin,
          disabled: disabled,
          uid: Base.decode64(uid)
        }
    }
  end

  defp update_state(device, {:ok, %{"name" => "set_temp_limits", "min" => min, "max" => max}}) do
    %{
      device
      | set_temp_limits: %{
          min: decode_temp(min),
          max: decode_temp(max)
        }
    }
  end

  defp update_state(device, {:ok, %{"name" => "ntp", "host" => host}}) do
    %{device | ntp: %{host: host}}
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
    %{
      device
      | versions: %{
          app: app,
          boot: boot,
          bt: bt,
          hw_id: hw_id,
          next_addr: next_addr,
          pos: pos,
          revert_avail: revert_avail,
          wifi: wifi
        }
    }
  end

  defp update_state(device, {:ok, unhandled}) do
    Logger.debug("Unhandled: #{inspect({device.id, unhandled})}")
    device
  end

  defp update_state(device, {:error, err}) do
    Logger.error("Payload decode error: #{err}")
    device
  end
end
