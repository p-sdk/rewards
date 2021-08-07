defmodule RewardsApp.Repo.Migrations.CreateRewards do
  use Ecto.Migration

  def change do
    create table(:rewards) do
      add :points, :integer, null: false
      add :pool_id, references(:pools, on_delete: :nothing), null: false
      add :receiver_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:rewards, [:pool_id])
    create index(:rewards, [:receiver_id])
  end
end
