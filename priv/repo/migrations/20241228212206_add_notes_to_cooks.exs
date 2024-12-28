defmodule OpenBoss.Repo.Migrations.AddNotesToCooks do
  use Ecto.Migration

  def change do
    alter table("cooks") do
      add :notes, :string, null: true
    end
  end
end
