defmodule OpenBoss.Cooks.Cook do
  @moduledoc """
  Cook schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias OpenBoss.Cooks.CookHistory
  alias OpenBoss.Devices.Device

  @required_fields [:name, :start_time, :target_temp]
  @fields @required_fields ++ [:device_id, :stop_time, :device_id, :notes]

  @type t() :: %__MODULE__{}

  schema "cooks" do
    field(:name, :string)
    field(:start_time, :utc_datetime_usec)
    field(:stop_time, :utc_datetime_usec)
    field(:target_temp, :float)
    field(:notes, :string)
    belongs_to(:device, Device)
    has_many(:cook_history, CookHistory)
  end

  @doc false
  def changeset(cook, attrs) do
    cook
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_cook_times()
    # the constraint name is *wrong* but that's the constraint error that
    # ecto raises, there are some comments in the elixir-sqlite repo regarding
    # this sort of problem:
    # https://github.com/elixir-sqlite/ecto_sqlite3/blob/main/lib/ecto/adapters/sqlite3.ex#L173-L189
    |> unique_constraint(:device,
      name: "cooks_device_id_index",
      message: "only 1 active cook allowed per device"
    )
  end

  @spec validate_cook_times(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_cook_times(changeset) do
    start_time = get_field(changeset, :start_time)
    stop_time = get_field(changeset, :stop_time)

    if start_time && stop_time && :lt == DateTime.compare(stop_time, start_time) do
      Ecto.Changeset.add_error(changeset, :stop_time, "cannot be less than start_time")
    else
      # if start_time is nil, the error is already recorded
      changeset
    end
  end
end
