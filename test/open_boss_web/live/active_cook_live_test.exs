defmodule OpenBossWeb.ActiveCookLiveTest do
  @moduledoc false

  use OpenBossWeb.ConnCase

  import Phoenix.LiveViewTest
  import OpenBoss.CooksFixtures

  defp create_active_cook(_) do
    active_cook =
      cook_fixture(start_time: ~U[2024-12-29 00:00:00.00Z])

    %{active_cook: active_cook}
  end

  describe "Index" do
    setup [:create_active_cook]

    test "lists all active_cooks", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/active_cooks")

      assert html =~ "Cooks"
    end
  end
end
