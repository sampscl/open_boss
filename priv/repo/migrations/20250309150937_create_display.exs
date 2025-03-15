defmodule OpenBoss.Repo.Migrations.CreateDisplay do
  use Ecto.Migration

  def change do
    create table(:display) do
      add :brightness, :integer
      add :path, :string
    end

    create_if_not_exists unique_index(:display, [:path])
  end
end
