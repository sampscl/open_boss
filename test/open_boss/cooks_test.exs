defmodule OpenBoss.CooksTest do
  use OpenBoss.DataCase

  alias OpenBoss.Cooks

  describe "cooks" do
    alias OpenBoss.Cooks.Cook
    alias OpenBoss.Devices.Device
    alias OpenBoss.Repo

    import OpenBoss.CooksFixtures
    import OpenBoss.DevicesFixtures

    @invalid_attrs %{name: nil}

    test "list_cooks/0 returns all cooks" do
      cook = cook_fixture() |> Repo.preload([:device])
      assert Cooks.list_cooks() == [cook]
    end

    test "get_cook!/1 returns the cook with given id" do
      cook = Cooks.get_cook!(cook_fixture().id)
      assert Cooks.get_cook!(cook.id) == cook
    end

    test "create_cook/1 with valid data creates a cook" do
      valid_attrs = %{name: "some name", start_time: ~U[2024-12-22 00:00:00.000000Z]}

      assert {:ok, %Cook{} = cook} = Cooks.create_cook(valid_attrs)
      assert cook.name == "some name"
      assert cook.start_time == ~U[2024-12-22 00:00:00.000000Z]
    end

    test "create_cook/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cooks.create_cook(@invalid_attrs)
    end

    test "create_cook/1 with invalid timestamps returns the correct error" do
      assert {:error,
              %Ecto.Changeset{errors: [stop_time: {"cannot be less than start_time", []}]}} =
               Cooks.create_cook(%{
                 name: "some name",
                 start_time: ~U[2024-12-22 00:00:00.000000Z],
                 stop_time: ~U[2024-12-21 00:00:00.000000Z]
               })
    end

    test "update_cook/2 with valid data updates the cook" do
      cook = cook_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Cook{} = cook} = Cooks.update_cook(cook, update_attrs)
      assert cook.name == "some updated name"
    end

    test "update_cook/2 with invalid data returns error changeset" do
      cook = Cooks.get_cook!(cook_fixture().id)
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

    test "can assign to device" do
      cook = cook_fixture()
      device = device_fixture()

      assert {:ok, updated} = Cooks.update_cook(cook, %{device_id: device.id})
      assert updated.device_id == device.id
    end

    test "device relation can be broken" do
      device = device_fixture()
      cook = cook_fixture(%{device_id: device.id})

      {:ok, _} = Repo.delete(device)

      assert Repo.reload(cook).device_id == nil
    end

    test "cook get also preloads device" do
      device = device_fixture()
      cook = cook_fixture(%{device_id: device.id})
      assert %Device{} = Cooks.get_cook!(cook.id).device
    end

    test "multiple completed cooks assigned to single device" do
      device = device_fixture()

      _cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: ~U[2024-12-31 01:00:00Z]
        })

      _cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: nil
        })

      assert {:ok, _cook2} =
               Cooks.create_cook(%{
                 name: "some other cook",
                 device_id: device.id,
                 start_time: ~U[2024-12-31 01:00:00Z],
                 stop_time: ~U[2024-12-31 01:00:00Z]
               })
    end

    test "same device cannot have 2 active cooks" do
      device = device_fixture()

      _cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: nil
        })

      assert {:error, cs} =
               Cooks.create_cook(%{
                 name: "some other cook",
                 device_id: device.id,
                 start_time: ~U[2024-12-31 01:00:00Z],
                 stop_time: nil
               })

      assert {"only 1 active cook allowed per device",
              [constraint: :unique, constraint_name: "cooks_device_id_index"]} =
               Keyword.fetch!(cs.errors, :device)
    end
  end
end
