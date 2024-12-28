defmodule OpenBoss.Repo.Migrations.CreateCooks do
  use Ecto.Migration

  def change do
    create table(:cooks) do
      add(:name, :string)
      add(:device_id, references(:devices, on_update: :nilify_all), null: true)
      add(:start_time, :utc_datetime_usec, null: false)
      add(:stop_time, :utc_datetime_usec, null: true)
    end
  end
end
