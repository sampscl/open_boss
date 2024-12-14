defmodule OpenBoss.Repo.Migrations.AddNameToDevices do
  use Ecto.Migration

  def change do
    alter table("devices") do
      add(:name, :string, null: true)
    end
  end
end
