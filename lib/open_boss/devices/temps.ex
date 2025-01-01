defmodule OpenBoss.Devices.Temps do
  @moduledoc """
  Temperatures schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:pit_1, :meat_1, :pit_2, :meat_2]

  @primary_key false

  @type t() :: %__MODULE__{
          pit_1: float() | nil,
          meat_1: float() | nil,
          pit_2: float() | nil,
          meat_2: float() | nil
        }

  @derive {Jason.Encoder, only: @fields}

  schema "temps" do
    field(:pit_1, :float)
    field(:meat_1, :float)
    field(:pit_2, :float)
    field(:meat_2, :float)
  end

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(temps, params) do
    temps
    |> cast(params, @fields)
  end
end
