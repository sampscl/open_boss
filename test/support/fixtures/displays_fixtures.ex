defmodule OpenBoss.DisplaysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OpenBoss.Displays` context.
  """

  @doc """
  Generate a display.
  """
  def display_fixture(attrs \\ %{}) do
    {:ok, display} =
      attrs
      |> Enum.into(%{
        brightness: 42,
        path: "/dev/null"
      })
      |> OpenBoss.Displays.create_display()

    display
  end
end
