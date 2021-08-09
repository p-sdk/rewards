defmodule RewardsApp.Rewards.Reward do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rewards" do
    field :points, :integer
    belongs_to :pool, RewardsApp.Rewards.Pool
    belongs_to :receiver, RewardsApp.Users.User

    timestamps()
  end

  @doc false
  def changeset(reward, attrs) do
    reward
    |> cast(attrs, [:points, :pool_id, :receiver_id])
    |> validate_required([:points, :pool_id, :receiver_id])
    |> validate_number(:points, greater_than: 0)
    |> assoc_constraint(:pool)
    |> assoc_constraint(:receiver)
  end
end
