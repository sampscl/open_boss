defmodule OpenBoss.Target.Network do
  @moduledoc """
  Target implementation
  """
  alias OpenBoss.Network
  alias OpenBoss.Network.Adapter
  alias OpenBoss.Network.WifiConfiguration

  require Logger

  @behaviour Network

  @impl Network
  def list_adapters do
    Enum.reduce(VintageNet.configured_interfaces(), [], fn interface, acc ->
      config = VintageNet.get_configuration(interface)

      changeset_from_config(%Adapter{id: interface, mutable: true}, config)
      |> Ecto.Changeset.apply_action(:list_adapters)
      |> case do
        {:ok, adapter} ->
          [adapter | acc]

        {:error, _changeset} ->
          Logger.debug("Ignored adapter #{interface}")
          acc
      end
    end)
  end

  @impl Network
  def get_adapter!(interface) do
    config = VintageNet.get_configuration(interface)

    changeset_from_config(%Adapter{id: interface, mutable: true}, config)
    |> Ecto.Changeset.apply_action!(:get_adapter!)
  end

  @impl Network
  def apply_configuration(%Adapter{type: VintageNetEthernet}) do
    raise("Not implemented")
  end

  @impl Network
  def apply_configuration(%Adapter{
        id: id,
        type: VintageNetWiFi,
        ipv4: %{method: :dhcp},
        configuration: %{networks: networks}
      }) do
    networks =
      Enum.map(networks, fn network ->
        %{
          mode: :infrastructure,
          psk: network.psk,
          ssid: network.ssid,
          key_mgmt: :wpa_psk
        }
      end)

    config = %{
      type: VintageNetWiFi,
      ipv4: %{method: :dhcp},
      networks: networks
    }

    VintageNet.configure(id, config)
  end

  @spec changeset_from_config(Adapter.t(), map()) :: Ecto.Changeset.t()
  defp changeset_from_config(adapter, config)

  defp changeset_from_config(
         adapter,
         %{
           type: VintageNetWiFi = type,
           ipv4: ipv4
         } = config
       ) do
    {:ok, configuration} =
      WifiConfiguration.changeset_from_vintage_net_config(config)
      |> Ecto.Changeset.apply_action(:apply)

    Adapter.changeset(adapter, %{
      mutable: true,
      type: type,
      ipv4: ipv4,
      configuration: configuration
    })
  end

  defp changeset_from_config(adapter, config) do
    Adapter.changeset(adapter, %{
      mutable: true,
      type: config[:type],
      ipv4: config[:ipv4],
      configuration: %{}
    })
  end
end
