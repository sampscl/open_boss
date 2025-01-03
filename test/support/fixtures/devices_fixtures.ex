defmodule OpenBoss.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OpenBoss.Devices` context.
  """

  alias OpenBoss.Devices.Device

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    params =
      Map.merge(
        %{
          id: 1,
          name: "fixture",
          ip: "127.0.0.1",
          port: 1883,
          requested_temp: nil,
          set_temp: 107.3,
          temps: %{
            pit_1: nil,
            meat_1: 20.1,
            pit_2: nil,
            meat_2: nil
          },
          blower: 0.0,
          protocol_version: 2,
          hw_id: nil,
          device_id: nil,
          uid: nil,
          pin: nil,
          disabled: nil,
          min_temp: 37.8,
          max_temp: 232.2,
          ntp_host: "time.google.com",
          app_version: "4.25.1",
          boot_version: "0.0.0",
          bt_version: "0.0.0",
          hw_id_version: 10,
          next_addr_version: 528_384,
          pos_version: 0,
          revert_avail_version: nil,
          wifi_version: "0.0.0",
          last_communication: ~U[1970-01-01 00:00:00Z],
          inserted_at: ~U[2024-12-13 14:24:47Z],
          updated_at: ~U[2024-12-13 16:27:49Z]
        },
        attrs
      )

    {:ok, device} =
      Device.changeset(%Device{}, params)
      |> OpenBoss.Repo.insert()

    device
  end
end
