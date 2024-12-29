defmodule OpenBoss.Cooks.Cook do
  @moduledoc """
  Cook schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias OpenBoss.Devices.Device

  @required_fields [:name, :start_time]
  @fields @required_fields ++ [:device_id, :stop_time, :device_id, :notes]

  @type t() :: %__MODULE__{}

  schema "cooks" do
    field(:name, :string)
    field(:start_time, :utc_datetime_usec)
    field(:stop_time, :utc_datetime_usec)
    field(:notes, :string)
    belongs_to(:device, Device)
  end

  @doc false
  def changeset(cook, attrs) do
    cook
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_cook_times()
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
