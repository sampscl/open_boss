defmodule OpenBossWeb.CookLiveHistoryTest do
  use OpenBossWeb.ConnCase

  import Phoenix.LiveViewTest
  import OpenBoss.CooksFixtures

  defp create_cook(_) do
    cook = cook_fixture()
    %{cook: cook}
  end

  describe "History" do
    setup [:create_cook]

    test "Shows history", %{conn: conn, cook: cook} do
      {:ok, _history_live, html} = live(conn, ~p"/cooks/#{cook}/history")

      assert html =~ cook.name
    end
  end
end
