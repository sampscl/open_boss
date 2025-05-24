defmodule OpenBoss.Network.Adapter do
  @moduledoc """
  Adapter structure for integrating vintage net and live view
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  @required [:id, :configuration]
  @fields @required ++ [:mutable]

  @types %{
    VintageNetEthernet => "Ethernet",
    VintageNetWiFi => "WiFi",
    VintageNetDirect => "Direct"
  }

  @primary_key false
  embedded_schema do
    field(:id, :string, primary_key: true)
    field(:mutable, :boolean, default: false)
    # See development.md for examples for what VintageNet provides; this
    # field holds a map of parameters that will have the general shape:
    # %{
    #   "addresses" => [
    #     %{
    #       scope: :universe,
    #       netmask: {255, 255, 255, 0},
    #       family: :inet,
    #       address: {192, 168, 86, 22},
    #       prefix_length: 24
    #     }
    #   ],
    #  "type" => VintageNetWiFi
    # }
    field(:configuration, :map)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t(t())
  def changeset(%__MODULE__{} = adapter, params) do
    adapter
    |> cast(params, @fields)
    |> validate_required(@required)
  end

  @spec connection_name(atom()) :: String.t()
  def connection_name(:disconnected), do: "Disconnected"
  def connection_name(:internet), do: "Connected (internet)"
  def connection_name(:connected), do: "Connected (no internet)"
  def connection_name(unknown), do: "Unknown (#{inspect(unknown)})"

  @spec type_name(atom()) :: String.t()
  def type_name(type) do
    Map.fetch!(@types, type)
  end

  @spec address_string(map()) :: String.t()
  def address_string(ip) do
    netmask = Tuple.to_list(ip.netmask) |> Enum.join(".")
    "#{VintageNet.IP.ip_to_string(ip.address)}/#{netmask}"
  end

  @spec ap_string(VintageNetWiFi.AccessPoint.t()) :: String.t()
  def ap_string(ap) do
    name =
      with "" <- ap.ssid do
        ap.bssid
      end

    radio =
      case ap.band do
        :wifi_5_ghz ->
          "5GHz channel #{ap.channel}"

        :wifi_2_4_ghz ->
          "2.4GHz channel #{ap.channel}"

        _ ->
          "unknown"
      end

    "#{name} #{ap.signal_percent}, #{radio}"
  end
end
