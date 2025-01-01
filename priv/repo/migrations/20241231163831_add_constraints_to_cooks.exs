defmodule OpenBoss.Repo.Migrations.AddConstraintsToCooks do
  use Ecto.Migration

  def change do
    # partial unique index for active cooks
    create index(:cooks, [:device_id],
             unique: true,
             where: "stop_time IS NULL AND device_id IS NOT NULL",
             name: "cooks_device_id_uniqueness_index"
           )
  end
end
