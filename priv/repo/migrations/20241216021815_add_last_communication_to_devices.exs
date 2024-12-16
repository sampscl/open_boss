defmodule OpenBoss.Repo.Migrations.AddLastCommunicationToDevices do
  use Ecto.Migration

  def change do
    alter table("devices") do
      add(:last_communication, :utc_datetime_usec, null: false)
    end
  end
end
