defmodule OpenBoss.Devices.DeviceTest do
  use OpenBoss.DataCase

  alias OpenBoss.Devices.Device

  @valid_attrs %{
    id: 1,
    ip: "192.168.1.1",
    port: 8080,
    requested_temp: 200.0,
    set_temp: 200.0,
    blower: 50.0,
    protocol_version: 1,
    hw_id: 123,
    device_id: 456,
    uid: <<1, 2, 3, 4>>,
    pin: 1234,
    disabled: false,
    min_temp: 100.0,
    max_temp: 300.0,
    ntp_host: "pool.ntp.org",
    app_version: "1.0.0",
    boot_version: "1.0.0",
    bt_version: "1.0.0",
    hw_id_version: 1,
    next_addr_version: 1,
    pos_version: 1,
    revert_avail_version: true,
    wifi_version: "1.0.0",
    name: "Test Device",
    last_communication: ~U[2023-01-01 00:00:00Z]
  }

  test "changeset with valid attributes" do
    changeset = Device.changeset(%Device{}, @valid_attrs)
    assert changeset.valid?
    assert Ecto.Changeset.apply_changes(changeset).online? == false
  end

  test "changeset with online? set to true" do
    changeset = Device.changeset(%Device{}, Map.put(@valid_attrs, :online?, true))
    assert changeset.valid?
    assert changeset.changes.online? == true
  end

  test "get_name/1 returns name if present" do
    device = %Device{name: "Test Device"}
    assert Device.get_name(device) == "Test Device"
  end

  test "get_name/1 returns id if name is nil" do
    device = build(:device, %{name: "1"})
    assert Device.get_name(device) == "1"
  end

  test "validate_temp/3 validates temperature within range" do
    changeset =
      Device.changeset(build(:device), %{min_temp: 100.0, max_temp: 300.0, set_temp: 200.0})

    assert changeset.valid?
  end

  test "validate_temp/3 invalidates temperature out of range" do
    changeset =
      Device.changeset(build(:device), %{min_temp: 100.0, max_temp: 300.0, set_temp: 400.0})

    refute changeset.valid?
    assert "must be <= 300.0C" in errors_on(changeset).set_temp
  end
end
