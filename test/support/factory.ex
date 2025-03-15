defmodule OpenBoss.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: OpenBoss.Repo

  def adapter_factory do
    %OpenBoss.Network.Adapter{
      id: "some adapter",
      mutable: true,
      type: VintageNetWiFi,
      configuration: build(:wifi_configuration),
      ipv4: build(:ipv4)
    }
  end

  def wifi_configuration_factory do
    %OpenBoss.Network.WifiConfiguration{
      networks: [%{ssid: "some ssid", psk: "some secret"}]
    }
  end

  def ipv4_factory do
    %OpenBoss.Network.Ipv4{
      method: :dhcp
    }
  end

  def device_factory do
    %OpenBoss.Devices.Device{
      id: 1,
      ip: "192.168.1.1",
      port: 8080,
      requested_temp: 200.0,
      set_temp: 200.0,
      blower: 50.0,
      protocol_version: 1,
      hw_id: 123,
      device_id: 456,
      uid: <<1, 2, 3, 4>>,
      pin: 1234,
      disabled: false,
      min_temp: 100.0,
      max_temp: 300.0,
      ntp_host: "pool.ntp.org",
      app_version: "1.0.0",
      boot_version: "1.0.0",
      bt_version: "1.0.0",
      hw_id_version: 1,
      next_addr_version: 1,
      pos_version: 1,
      revert_avail_version: true,
      wifi_version: "1.0.0",
      name: "Test Device",
      last_communication: ~U[2023-01-01 00:00:00Z]
    }
  end
end
