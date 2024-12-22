defmodule OpenBossWeb.DeviceLiveTest do
  use OpenBossWeb.ConnCase

  import Phoenix.LiveViewTest
  import OpenBoss.DevicesFixtures

  alias OpenBoss.Devices.Device

  # @create_attrs %{}
  @update_attrs %{"name" => "a different name", "set_temp" => "110"}
  @invalid_attrs %{"set_temp" => "0"}

  defp create_device(_) do
    device = device_fixture()
    %{device: device}
  end

  describe "Index" do
    setup [:create_device]

    test "lists all devices", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/devices")

      assert html =~ "fixture"
    end

    test "updates device in listing", %{conn: conn, device: device} do
      {:ok, index_live, _html} = live(conn, ~p"/devices")

      assert index_live
             |> element("#devices-#{device.id} a", "Configure...")
             |> render_click() =~
               Device.get_name(device)

      assert_patch(index_live, ~p"/devices/#{device.id}/edit")

      assert index_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "must be &gt;="

      assert index_live
             |> form("#device-form", device: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/devices")

      html = render(index_live)
      assert html =~ "a different name updated successfully"
    end
  end

  describe "Show" do
    setup [:create_device]

    test "displays device", %{conn: conn, device: device} do
      {:ok, _show_live, html} = live(conn, ~p"/devices/#{device}")

      assert html =~ "Device"
    end

    test "updates device within modal", %{conn: conn, device: device} do
      {:ok, show_live, _html} = live(conn, ~p"/devices/#{device}")

      assert show_live |> element("a", "Configure...") |> render_click() =~
               "Configure..."

      assert_patch(show_live, ~p"/devices/#{device.id}/show/edit")

      assert show_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "must be &gt;="

      assert show_live
             |> form("#device-form", device: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/devices/#{device.id}")

      html = render(show_live)
      assert html =~ "a different name updated successfully"
    end
  end
end
