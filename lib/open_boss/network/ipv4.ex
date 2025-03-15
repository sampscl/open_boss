defmodule OpenBoss.Network.Ipv4 do
  @moduledoc """
  IPv4 schema for vintage net
  """
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:method]

  @primary_key false

  @type t() :: %__MODULE__{}

  embedded_schema do
    field(:method, Ecto.Enum, values: [:dhcp])
  end

  @spec changeset(t() | map() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t(t())
  def changeset(item, attrs \\ %{})

  def changeset(item, attrs) when is_struct(item, __MODULE__) do
    item
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  def changeset(item, attrs) when is_map(item) do
    struct(__MODULE__, item)
    |> changeset(attrs)
  end
end
