defmodule OpenBoss.Repo.Migrations.AddDevices do
  use Ecto.Migration

  def change do
    create table("devices", primary_key: false) do
      add(:id, :integer, primary_key: true)
      add(:ip, :string, null: true)
      add(:port, :integer, null: true)
      add(:requested_temp, :float, null: true)
      add(:set_temp, :float, null: true)
      add(:temps, :map, null: true)
      add(:blower, :float, null: true)
      add(:protocol_version, :integer, null: true)
      add(:hw_id, :integer, null: true)
      add(:device_id, :integer, null: true)
      add(:uid, :binary, null: true)
      add(:pin, :integer, null: true)
      add(:disabled, :boolean, null: true)
      add(:min_temp, :float, null: true)
      add(:max_temp, :float, null: true)
      add(:ntp_host, :string, null: true)
      add(:app_version, :string, null: true)
      add(:boot_version, :string, null: true)
      add(:bt_version, :string, null: true)
      add(:hw_id_version, :integer, null: true)
      add(:next_addr_version, :integer, null: true)
      add(:pos_version, :integer, null: true)
      add(:revert_avail_version, :boolean, null: true)
      add(:wifi_version, :string, null: true)
      timestamps(type: :utc_datetime)
    end
  end
end
