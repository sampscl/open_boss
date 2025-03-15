defmodule OpenBossWeb.NetworkLiveTest do
  use OpenBossWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    test "lists all adapters", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/cooks")

      assert html =~ "Network"
    end
  end

  describe "Show" do
  end
end
