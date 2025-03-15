defmodule OpenBossWeb.DisplayLiveTest do
  use OpenBossWeb.ConnCase

  import Phoenix.LiveViewTest
  import OpenBoss.DisplaysFixtures

  @update_attrs %{brightness: 43}
  @invalid_attrs %{brightness: nil}

  defp create_display(_) do
    display = display_fixture()
    %{display: display}
  end

  describe "Index" do
    setup [:create_display]

    test "lists all display", %{conn: conn, display: display} do
      {:ok, _index_live, html} = live(conn, ~p"/display")

      assert html =~ "Displays"
      assert html =~ display.path
    end

    test "updates display in listing", %{conn: conn, display: display} do
      {:ok, index_live, _html} = live(conn, ~p"/display")

      assert index_live |> element("#displays-#{display.id} a", "Edit") |> render_click() =~
               "Edit"

      assert_patch(index_live, ~p"/display/#{display}/edit")

      assert index_live
             |> form("#display-form", display: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#display-form", display: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/display")

      html = render(index_live)
      assert html =~ "Display updated successfully"
    end
  end

  describe "Show" do
    setup [:create_display]

    test "displays display", %{conn: conn, display: display} do
      {:ok, _show_live, html} = live(conn, ~p"/display/#{display}")

      assert html =~ "Show Display"
      assert html =~ display.path
    end

    test "updates display within modal", %{conn: conn, display: display} do
      {:ok, show_live, _html} = live(conn, ~p"/display/#{display}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Display"

      assert_patch(show_live, ~p"/display/#{display}/show/edit")

      assert show_live
             |> form("#display-form", display: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#display-form", display: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/display/#{display}")

      html = render(show_live)
      assert html =~ "Display updated successfully"
    end
  end
end
