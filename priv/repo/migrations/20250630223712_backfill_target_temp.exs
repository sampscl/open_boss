defmodule OpenBoss.Repo.Migrations.BackfillTargetTemp do
  use Ecto.Migration

  def up do
    execute("""
    UPDATE cooks
    SET target_temp = 100.0
    WHERE target_temp IS NULL
    """)
  end

  def down do
    # No-op: cannot revert data update
  end
end
