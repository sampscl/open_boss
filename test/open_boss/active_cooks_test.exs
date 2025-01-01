defmodule OpenBoss.ActiveCooksTest do
  use OpenBoss.DataCase

  describe "list_active_cooks/0" do
    alias OpenBoss.ActiveCooks
    alias OpenBoss.Repo

    import OpenBoss.CooksFixtures
    import OpenBoss.DevicesFixtures

    test "returns all active cooks and no inactive" do
      device = device_fixture()

      cook =
        cook_fixture(%{start_time: ~U[2024-12-29 00:00:00.00Z], device_id: device.id})
        |> Repo.preload(:device)

      _cook2 =
        cook_fixture(%{
          start_time: ~U[2024-12-29 00:00:00.00Z],
          stop_time: ~U[2024-12-29 01:00:00.00Z]
        })

      assert ActiveCooks.list_active_cooks() == [cook]
    end
  end

  describe "get_active_cook/1" do
    alias OpenBoss.ActiveCooks
    import OpenBoss.CooksFixtures
    import OpenBoss.DevicesFixtures

    test "with no active cooks" do
      device = device_fixture()

      _cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: ~U[2024-12-31 01:00:00Z]
        })

      assert nil == ActiveCooks.get_active_cook(device.id, ~U[2024-12-31 02:00:00Z])
    end

    test "with active cook" do
      device = device_fixture()

      cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: ~U[2024-12-31 01:00:00Z]
        })

      assert cook == ActiveCooks.get_active_cook(device.id, ~U[2024-12-31 01:00:00Z])
    end
  end

  describe "maybe_add_cook_history/1" do
    alias OpenBoss.ActiveCooks
    alias OpenBoss.Cooks

    import OpenBoss.CooksFixtures
    import OpenBoss.DevicesFixtures

    test "updates history for existing but inactive" do
      device =
        device_fixture(%{last_communication: ~U[2024-12-31 00:30:00.00Z]})

      _cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: ~U[2024-12-31 01:00:00Z]
        })

      assert {:ok, %{cook_history: cook_history}} = ActiveCooks.maybe_add_cook_history(device)
      assert cook_history.timestamp == device.last_communication
      assert cook_history.device_state.set_temp == 107.3
      assert cook_history.device_state.blower == 0.0
      assert cook_history.device_state.temps.pit_1 == nil
      assert cook_history.device_state.temps.pit_2 == nil
      assert cook_history.device_state.temps.meat_1 == 20.1
      assert cook_history.device_state.temps.meat_2 == nil
    end

    test "updates history for active cook" do
      device =
        device_fixture(%{last_communication: ~U[2024-12-31 00:30:00.00Z]})

      _cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: nil
        })

      assert {:ok, %{cook_history: _cook_history}} = ActiveCooks.maybe_add_cook_history(device)
    end

    test "does not update history when beyond cook time window" do
      device =
        device_fixture(%{last_communication: ~U[2024-12-31 02:00:00.00Z]})

      _cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: ~U[2024-12-31 01:00:00Z]
        })

      assert {:error, :cook, :no_cook, _} = ActiveCooks.maybe_add_cook_history(device)
    end

    test "does not update history when before cook time window" do
      device =
        device_fixture(%{last_communication: ~U[2024-12-30 23:00:00.00Z]})

      _cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: ~U[2024-12-31 01:00:00Z]
        })

      assert {:error, :cook, :no_cook, _} = ActiveCooks.maybe_add_cook_history(device)
    end

    test "cannot delete a cook with history" do
      device =
        device_fixture(%{last_communication: ~U[2024-12-31 00:30:00.00Z]})

      cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: ~U[2024-12-31 01:00:00Z]
        })

      assert {:ok, %{cook_history: _cook_history}} = ActiveCooks.maybe_add_cook_history(device)

      assert_raise Ecto.ConstraintError, fn -> Cooks.delete_cook(cook) end
    end

    test "manually cascade delete cook with history works" do
      device =
        device_fixture(%{last_communication: ~U[2024-12-31 00:30:00.00Z]})

      cook =
        cook_fixture(%{
          device_id: device.id,
          start_time: ~U[2024-12-31 00:00:00Z],
          stop_time: ~U[2024-12-31 01:00:00Z]
        })

      assert {:ok, %{cook_history: cook_history}} = ActiveCooks.maybe_add_cook_history(device)

      assert {:ok, _} =
               Ecto.Multi.new()
               |> Ecto.Multi.delete(:cook_history, cook_history)
               |> Ecto.Multi.delete(:cook, cook)
               |> Repo.transaction()
    end
  end
end
