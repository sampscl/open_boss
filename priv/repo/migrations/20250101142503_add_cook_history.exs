defmodule OpenBoss.Repo.Migrations.AddCookHistory do
  use Ecto.Migration

  def change do
    create table(:cook_histories, primary_key: false) do
      add(:id, :id, primary_key: true)

      add(:cook_id, references(:cooks, on_delete: :restrict, name: "cook_histories_cook_id_fkey"),
        null: false
      )

      add(:device_state, :map, null: false)
      add(:timestamp, :utc_datetime_usec, null: false)
    end
  end
end
