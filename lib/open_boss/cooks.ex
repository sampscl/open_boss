defmodule OpenBoss.Cooks do
  @moduledoc """
  The Cooks context.
  """

  import Ecto.Query, warn: false
  alias OpenBoss.Repo

  alias OpenBoss.Cooks.Cook

  @doc """
  Returns the list of cooks.

  ## Examples

      iex> list_cooks()
      [%Cook{}, ...]

  """
  def list_cooks do
    Repo.all(from(c in Cook, preload: :device))
  end

  @doc """
  Gets a single cook.

  Raises `Ecto.NoResultsError` if the Cook does not exist.

  ## Examples

      iex> get_cook!(123)
      %Cook{}

      iex> get_cook!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cook!(id), do: from(c in Cook, where: c.id == ^id, preload: :device) |> Repo.one!()

  @doc """
  Creates a cook.

  ## Examples

      iex> create_cook(%{field: value})
      {:ok, %Cook{}}

      iex> create_cook(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cook(attrs \\ %{}) do
    %Cook{}
    |> Cook.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cook.

  ## Examples

      iex> update_cook(cook, %{field: new_value})
      {:ok, %Cook{}}

      iex> update_cook(cook, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cook(%Cook{} = cook, attrs) do
    cook
    |> Cook.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cook.

  ## Examples

      iex> delete_cook(cook)
      {:ok, %Cook{}}

      iex> delete_cook(cook)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cook(%Cook{} = cook) do
    Repo.delete(cook)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cook changes.

  ## Examples

      iex> change_cook(cook)
      %Ecto.Changeset{data: %Cook{}}

  """
  def change_cook(%Cook{} = cook, attrs \\ %{}) do
    Cook.changeset(cook, attrs)
  end
end
