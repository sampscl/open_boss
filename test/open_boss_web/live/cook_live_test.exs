defmodule OpenBossWeb.CookLiveTest do
  use OpenBossWeb.ConnCase

  import Phoenix.LiveViewTest
  import OpenBoss.CooksFixtures

  @create_attrs %{name: "a cook", start_time: "2024-12-22 00:00"}
  @update_attrs %{name: "a different cook"}
  @invalid_attrs %{name: nil}

  defp create_cook(_) do
    cook = cook_fixture()
    %{cook: cook}
  end

  defp set_timezone(view, timezone \\ "Etc/UTC") do
    render_hook(view, "set_timezone", %{"timezone" => timezone})
  end

  describe "Index" do
    setup [:create_cook]

    test "lists all cooks", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/cooks")

      assert html =~ "Listing Cooks"
    end

    test "saves new cook", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cooks")

      set_timezone(index_live)

      assert index_live |> element("a", "New Cook") |> render_click() =~
               "New Cook"

      assert_patch(index_live, ~p"/cooks/new")

      assert index_live
             |> form("#cook-form", cook: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cook-form", cook: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cooks")

      html = render(index_live)
      assert html =~ "Cook created successfully"
    end

    test "updates cook in listing", %{conn: conn, cook: cook} do
      {:ok, index_live, _html} = live(conn, ~p"/cooks")

      set_timezone(index_live)

      assert index_live |> element("#cooks-#{cook.id} a", "Edit") |> render_click() =~
               "Edit Cook"

      assert_patch(index_live, ~p"/cooks/#{cook.id}/edit")

      assert index_live
             |> form("#cook-form", cook: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # assert index_live
      #        |> form("#cook-form", cook: @update_attrs)
      #        |> render_submit()

      # assert_patch(index_live, ~p"/cooks")

      # html = render(index_live)
      # assert html =~ "Cook updated successfully"
    end

    test "deletes cook in listing", %{conn: conn, cook: cook} do
      {:ok, index_live, _html} = live(conn, ~p"/cooks")

      set_timezone(index_live)

      assert index_live |> element("#cooks-#{cook.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cooks-#{cook.id}")
    end
  end

  describe "Show" do
    setup [:create_cook]

    test "displays cook", %{conn: conn, cook: cook} do
      {:ok, _show_live, html} = live(conn, ~p"/cooks/#{cook}")

      assert html =~ "Show Cook"
    end

    test "updates cook within modal", %{conn: conn, cook: cook} do
      {:ok, show_live, _html} = live(conn, ~p"/cooks/#{cook}")

      set_timezone(show_live)

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Cook"

      assert_patch(show_live, ~p"/cooks/#{cook.id}/show/edit")

      assert show_live
             |> form("#cook-form", cook: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#cook-form", cook: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cooks/#{cook.id}")

      html = render(show_live)
      assert html =~ "Cook updated successfully"
    end
  end
end
