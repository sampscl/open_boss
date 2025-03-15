defmodule OpenBoss.DisplaysTest do
  use OpenBoss.DataCase

  alias OpenBoss.Displays

  describe "display" do
    alias OpenBoss.Displays.Display

    import OpenBoss.DisplaysFixtures

    @invalid_attrs %{path: "", brightness: nil}

    test "list_display/0 returns all display" do
      display = display_fixture()
      assert Displays.list_display() == [display]
    end

    test "get_display!/1 returns the display with given id" do
      display = display_fixture()
      assert Displays.get_display!(display.id) == display
    end

    test "create_display/1 with valid data creates a display" do
      valid_attrs = %{path: "/dev/null", brightness: 42}

      assert {:ok, %Display{} = display} = Displays.create_display(valid_attrs)
      assert display.path == "/dev/null"
      assert display.brightness == 42
    end

    test "create_display/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Displays.create_display(@invalid_attrs)
    end

    test "update_display/2 with valid data updates the display" do
      display = display_fixture()
      update_attrs = %{brightness: 43}

      assert {:ok, %Display{} = display} = Displays.update_display(display, update_attrs)
      assert display.brightness == 43
    end

    test "update_display/2 with invalid data returns error changeset" do
      display = display_fixture()
      assert {:error, %Ecto.Changeset{}} = Displays.update_display(display, @invalid_attrs)
      assert display == Displays.get_display!(display.id)
    end

    test "delete_display/1 deletes the display" do
      display = display_fixture()
      assert {:ok, %Display{}} = Displays.delete_display(display)
      assert_raise Ecto.NoResultsError, fn -> Displays.get_display!(display.id) end
    end

    test "change_display/1 returns a display changeset" do
      display = display_fixture()
      assert %Ecto.Changeset{} = Displays.change_display(display)
    end
  end
end
