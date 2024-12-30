defmodule OpenBoss.ActiveCooksTest do
  use OpenBoss.DataCase

  describe "active_cooks/0" do
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
end
