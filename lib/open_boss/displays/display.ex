defmodule OpenBoss.Displays.Display do
  @moduledoc """
  Display schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  schema "display" do
    field :path, :string
    field :brightness, :integer
  end

  @doc false
  def changeset(display, attrs) do
    display
    |> cast(attrs, [:brightness, :path])
    |> validate_required([:brightness, :path])
    |> unique_constraint(:path)
    |> validate_path()
    |> validate_number(:brightness, greater_than_or_equal_to: 1)
    |> validate_number(:brightness, less_than_or_equal_to: 100)
  end

  @spec validate_path(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_path(changeset) do
    path = get_field(changeset, :path, "")

    if is_binary(path) and File.exists?(path) do
      changeset
    else
      add_error(changeset, :path, "path must exist")
    end
  end
end
