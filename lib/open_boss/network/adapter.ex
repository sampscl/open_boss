defmodule OpenBoss.Network.Adapter do
  @moduledoc """
  Adapter structure for integrating vintage net and live view
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias OpenBoss.Network.Ipv4

  @type t() :: %__MODULE__{}

  @required [:id]
  @fields @required ++ [:configuration, :mutable, :type]

  @types %{VintageNetEthernet => "Ethernet", VintageNetWiFi => "WiFi"}

  @primary_key false
  embedded_schema do
    field(:id, :string, primary_key: true)
    field(:mutable, :boolean, default: false)
    field(:type, Ecto.Enum, values: Map.keys(@types))
    field(:configuration, :map)
    embeds_one(:ipv4, Ipv4)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t(t())
  def changeset(%__MODULE__{} = adapter, params) do
    adapter
    |> cast(params, @fields)
    |> cast_embed(:ipv4)
    |> validate_required(@required)
  end

  @spec type_name(t()) :: String.t()
  def type_name(%{type: type}) do
    Map.fetch!(@types, type)
  end
end
