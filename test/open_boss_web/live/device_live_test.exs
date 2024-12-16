defmodule OpenBossWeb.DeviceLiveTest do
  use OpenBossWeb.ConnCase

  import Phoenix.LiveViewTest
  import OpenBoss.DevicesFixtures

  # @create_attrs %{}
  @update_attrs %{name: "a different name", set_temp: "100"}
  @invalid_attrs %{set_temp: "must be a number"}

  defp create_device(_) do
    device = device_fixture()
    %{device: device}
  end

  describe "Index" do
    setup [:create_device]

    test "lists all devices", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/devices")

      assert html =~ "127.0.0.1:1883"
    end

    #   test "saves new device", %{conn: conn} do
    #     {:ok, index_live, _html} = live(conn, ~p"/devices")

    #     assert index_live |> element("a", "New Device") |> render_click() =~
    #              "New Device"

    #     assert_patch(index_live, ~p"/devices/new")

    #     assert index_live
    #            |> form("#device-form", device: @invalid_attrs)
    #            |> render_change() =~ "can&#39;t be blank"

    #     assert index_live
    #            |> form("#device-form", device: @create_attrs)
    #            |> render_submit()

    #     assert_patch(index_live, ~p"/devices")

    #     html = render(index_live)
    #     assert html =~ "Device created successfully"
    #   end

    test "updates device in listing", %{conn: conn, device: device} do
      {:ok, index_live, _html} = live(conn, ~p"/devices")

      assert index_live
             |> element("#devices-#{device.id} a", "Configure...")
             |> render_click() =~
               OpenBoss.Devices.Device.get_name(device)

      assert_patch(index_live, ~p"/devices/#{device}/edit")

      index_live
      |> form("#device-form", device: @invalid_attrs)
      |> render_change()

      assert index_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # assert index_live
      #        |> form("#device-form", device: @update_attrs)
      #        |> render_submit()

      # assert_patch(index_live, ~p"/devices")

      # html = render(index_live)
      # assert html =~ "Device updated successfully"
    end

    #   test "deletes device in listing", %{conn: conn, device: device} do
    #     {:ok, index_live, _html} = live(conn, ~p"/devices")

    #     assert index_live |> element("#devices-#{device.id} a", "Delete") |> render_click()
    #     refute has_element?(index_live, "#devices-#{device.id}")
    #   end
    # end

    # describe "Show" do
    #   setup [:create_device]

    #   test "displays device", %{conn: conn, device: device} do
    #     {:ok, _show_live, html} = live(conn, ~p"/devices/#{device}")

    #     assert html =~ "Show Device"
    #   end

    #   test "updates device within modal", %{conn: conn, device: device} do
    #     {:ok, show_live, _html} = live(conn, ~p"/devices/#{device}")

    #     assert show_live |> element("a", "Edit") |> render_click() =~
    #              "Edit Device"

    #     assert_patch(show_live, ~p"/devices/#{device}/show/edit")

    #     assert show_live
    #            |> form("#device-form", device: @invalid_attrs)
    #            |> render_change() =~ "can&#39;t be blank"

    #     assert show_live
    #            |> form("#device-form", device: @update_attrs)
    #            |> render_submit()

    #     assert_patch(show_live, ~p"/devices/#{device}")

    #     html = render(show_live)
    #     assert html =~ "Device updated successfully"
    #   end
  end
end
