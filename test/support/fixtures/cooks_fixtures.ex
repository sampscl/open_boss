defmodule OpenBoss.CooksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OpenBoss.Cooks` context.
  """

  @doc """
  Generate a cook.
  """
  def cook_fixture(attrs \\ %{}) do
    {:ok, cook} =
      attrs
      |> Enum.into(%{
        cook_id: 42,
        name: "some name"
      })
      |> OpenBoss.Cooks.create_cook()

    cook
  end
end
