defmodule OpenBoss.Network.WifiConfigurationTest do
  use OpenBoss.DataCase

  alias OpenBoss.Network.WifiConfiguration

  test "changeset_from_vintage_net_config/1 parses valid config" do
    config = %{
      type: VintageNetWiFi,
      vintage_net_wifi: %{
        networks: [%{ssid: "home", psk: "very secret passphrase"}]
      },
      ipv4: %{method: :dhcp}
    }

    assert %{valid?: true} = cs = WifiConfiguration.changeset_from_vintage_net_config(config)
    assert {:ok, wifi} = Ecto.Changeset.apply_action(cs, :apply)
    assert [network] = wifi.networks
    assert network.ssid == "home"
    assert network.psk == "very secret passphrase"
  end

  test "changeset_from_vintage_net_config/1 parses valid config with no networks" do
    config = %{
      type: VintageNetWiFi,
      vintage_net_wifi: %{
        networks: []
      },
      ipv4: %{method: :dhcp}
    }

    assert %{valid?: true} = cs = WifiConfiguration.changeset_from_vintage_net_config(config)
    assert {:ok, wifi} = Ecto.Changeset.apply_action(cs, :apply)
    assert [] == wifi.networks
  end

  test "changeset_from_vintage_net_config/1 rejects invalid type" do
    config = %{
      type: Foo,
      vintage_net_wifi: %{
        networks: [%{ssid: "home", psk: "very secret passphrase"}]
      },
      ipv4: %{method: :dhcp}
    }

    assert_raise(FunctionClauseError, fn ->
      WifiConfiguration.changeset_from_vintage_net_config(config)
    end)
  end

  test "changeset_from_vintage_net_config/1 rejects invalid config" do
    config = %{
      type: VintageNetWiFi,
      vintage_net_wifi: nil,
      ipv4: %{method: :dhcp}
    }

    assert %{valid?: false} = cs = WifiConfiguration.changeset_from_vintage_net_config(config)

    assert {"vintage_net_wifi key expected in config", []} ==
             Keyword.fetch!(cs.errors, :vintage_net_wifi)
  end
end
