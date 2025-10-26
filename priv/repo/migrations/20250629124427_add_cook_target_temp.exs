defmodule OpenBoss.Repo.Migrations.AddCookTargetTemp do
  use Ecto.Migration

  def change do
    alter table("cooks") do
      # This needs to be null-able because sqlite does not
      # allow column changes (like adding constraints)
      add(:target_temp, :float, null: true)
    end
  end
end
