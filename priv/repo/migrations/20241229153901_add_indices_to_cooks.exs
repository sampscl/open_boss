defmodule OpenBoss.Repo.Migrations.AddIndicesToCooks do
  use Ecto.Migration

  def change do
    create index("cooks", [:start_time])
    create index("cooks", [:stop_time])
    create index("cooks", [:start_time, :stop_time])
    create index("cooks", [:name])
    create index("cooks", [:device_id])
  end
end
