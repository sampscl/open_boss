defmodule OpenBoss.Displays do
  @moduledoc """
  Displays context.
  """

  import Ecto.Query, warn: false
  alias OpenBoss.Repo

  alias OpenBoss.Displays.Display

  @callback apply_settings(Display.t()) :: :ok | {:error, any()}

  defdelegate apply_settings(display),
    to: Application.compile_env!(:open_boss, [__MODULE__, :implementation])

  @doc """
  Returns the list of display.

  ## Examples

      iex> list_display()
      [%Display{}, ...]

  """
  def list_display do
    Repo.all(Display)
  end

  @doc """
  Gets a single display.

  Raises `Ecto.NoResultsError` if the Display does not exist.

  ## Examples

      iex> get_display!(123)
      %Display{}

      iex> get_display!(456)
      ** (Ecto.NoResultsError)

  """
  def get_display!(id), do: Repo.get!(Display, id)

  @doc """
  Creates a display.

  ## Examples

      iex> create_display(%{field: value})
      {:ok, %Display{}}

      iex> create_display(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_display(attrs \\ %{}) do
    %Display{}
    |> Display.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a display.

  ## Examples

      iex> update_display(display, %{field: new_value})
      {:ok, %Display{}}

      iex> update_display(display, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_display(%Display{} = display, attrs) do
    display
    |> Display.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a display.

  ## Examples

      iex> delete_display(display)
      {:ok, %Display{}}

      iex> delete_display(display)
      {:error, %Ecto.Changeset{}}

  """
  def delete_display(%Display{} = display) do
    Repo.delete(display)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking display changes.

  ## Examples

      iex> change_display(display)
      %Ecto.Changeset{data: %Display{}}

  """
  def change_display(%Display{} = display, attrs \\ %{}) do
    Display.changeset(display, attrs)
  end
end
