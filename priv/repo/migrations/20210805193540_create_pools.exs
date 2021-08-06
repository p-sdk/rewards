defmodule RewardsApp.Repo.Migrations.CreatePools do
  use Ecto.Migration

  def change do
    create table(:pools) do
      add :remaining_points, :integer, null: false
      add :month, :integer, null: false
      add :year, :integer, null: false
      add :owner_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:pools, [:owner_id])
    create unique_index(:pools, [:month, :year, :owner_id])
  end
end
