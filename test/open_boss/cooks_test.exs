defmodule OpenBoss.CooksTest do
  use OpenBoss.DataCase

  alias OpenBoss.Cooks

  describe "cook" do
    alias OpenBoss.Cooks.Cook

    import OpenBoss.CooksFixtures

    @invalid_attrs %{name: nil, cook_id: nil}

    test "list_cook/0 returns all cook" do
      cook = cook_fixture()
      assert Cooks.list_cook() == [cook]
    end

    test "get_cook!/1 returns the cook with given id" do
      cook = cook_fixture()
      assert Cooks.get_cook!(cook.id) == cook
    end

    test "create_cook/1 with valid data creates a cook" do
      valid_attrs = %{name: "some name", cook_id: 42}

      assert {:ok, %Cook{} = cook} = Cooks.create_cook(valid_attrs)
      assert cook.name == "some name"
      assert cook.cook_id == 42
    end

    test "create_cook/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cooks.create_cook(@invalid_attrs)
    end

    test "update_cook/2 with valid data updates the cook" do
      cook = cook_fixture()
      update_attrs = %{name: "some updated name", cook_id: 43}

      assert {:ok, %Cook{} = cook} = Cooks.update_cook(cook, update_attrs)
      assert cook.name == "some updated name"
      assert cook.cook_id == 43
    end

    test "update_cook/2 with invalid data returns error changeset" do
      cook = cook_fixture()
      assert {:error, %Ecto.Changeset{}} = Cooks.update_cook(cook, @invalid_attrs)
      assert cook == Cooks.get_cook!(cook.id)
    end

    test "delete_cook/1 deletes the cook" do
      cook = cook_fixture()
      assert {:ok, %Cook{}} = Cooks.delete_cook(cook)
      assert_raise Ecto.NoResultsError, fn -> Cooks.get_cook!(cook.id) end
    end

    test "change_cook/1 returns a cook changeset" do
      cook = cook_fixture()
      assert %Ecto.Changeset{} = Cooks.change_cook(cook)
    end
  end
end
