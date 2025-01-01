defmodule OpenBoss.Cooks.CookHistory do
  @moduledoc """
  Cook history schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias OpenBoss.Cooks.Cook

  @required_fields [:cook_id, :device_state, :timestamp]

  @type t() :: %__MODULE__{}

  schema "cook_histories" do
    belongs_to(:cook, Cook)
    field(:device_state, :map)
    field(:timestamp, :utc_datetime_usec)
  end

  @doc false
  def changeset(cook_history, attrs) do
    cook_history
    |> cast(attrs, @required_fields)
  end
end
