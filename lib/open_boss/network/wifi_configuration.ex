defmodule OpenBoss.Network.WifiConfiguration do
  @moduledoc """
  Wifi configuration embedded schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  @type t() :: %__MODULE__{}

  embedded_schema do
    embeds_many :networks, WifiNetwork, on_replace: :delete, primary_key: false do
      field(:ssid, :string)
      field(:psk, :string, redact: true)
    end
  end

  @spec changeset(t() | map() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t(t())
  def changeset(item, attrs \\ %{})

  def changeset(item, attrs) when is_struct(item, __MODULE__) do
    item
    |> cast(attrs, [])
    |> cast_embed(:networks,
      with: fn wifi_network, attrs ->
        wifi_network
        |> cast(attrs, [:ssid, :psk])
        |> validate_required([:ssid, :psk])
        |> validate_length(:psk, count: :bytes, min: 8)
      end
    )
  end

  def changeset(item, attrs) when is_map(item) do
    struct(__MODULE__, item)
    |> changeset(attrs)
  end

  @spec changeset_from_vintage_net_config(map()) :: Ecto.Changeset.t()
  def changeset_from_vintage_net_config(%{
        type: VintageNetWiFi,
        vintage_net_wifi: %{networks: vintage_net_networks}
      }) do
    networks =
      Enum.reduce(vintage_net_networks, [], fn
        %{ssid: _ssid, psk: _psk} = network, acc ->
          [network | acc]

        _network, acc ->
          acc
      end)

    changeset(%{}, %{networks: networks})
  end

  def changeset_from_vintage_net_config(%{
        type: VintageNetWiFi,
        vintage_net_wifi: _invalid
      }) do
    changeset(%{}, %{})
    |> add_error(:vintage_net_wifi, "vintage_net_wifi key expected in config")
  end
end
