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
        name: "some name",
        target_temp: 100.0,
        start_time: ~U[2024-12-22 00:00:00.000000Z]
      })
      |> OpenBoss.Cooks.create_cook()

    cook
  end
end
