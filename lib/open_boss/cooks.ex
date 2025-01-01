defmodule OpenBoss.Cooks do
  @moduledoc """
  The Cooks context.
  """

  import Ecto.Query, warn: false
  alias OpenBoss.Cooks.CookHistory
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
    with {:ok, cook} <-
           %Cook{}
           |> Cook.changeset(attrs)
           |> Repo.insert() do
      {:ok, Repo.preload(cook, :device)}
    end
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
  Deletes a cook. This will raise `Ecto.ConstraintError`
  if the cook has history. Delete those first, then
  delete the cook instead. Note that a constraint can
  be handled with in a changeset, but this does not
  work properly for sqlite.

  See also the comments in `OpenBoss.Cooks.Cook.changeset/2`.

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
  Purge a cook: remove history and the cook
  """
  def purge_cook(%Cook{} = cook) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:cook_history, from(c in CookHistory, where: c.cook_id == ^cook.id))
    |> Ecto.Multi.delete(:cook, cook)
    |> Repo.transaction()
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
