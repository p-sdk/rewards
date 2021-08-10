defmodule RewardsApp.Rewards.Pool do
  use Ecto.Schema
  import Ecto.Changeset

  @default_pool_size 50

  schema "pools" do
    field :remaining_points, :integer, default: @default_pool_size
    field :month, :integer
    field :year, :integer
    belongs_to :owner, RewardsApp.Users.User
    has_many :rewards, RewardsApp.Rewards.Reward

    timestamps()
  end

  @doc false
  def changeset(pool, attrs) do
    pool
    |> cast(attrs, [:remaining_points, :month, :year, :owner_id])
    |> validate_required([:remaining_points, :month, :year, :owner_id])
    |> validate_number(:remaining_points, greater_than_or_equal_to: 0)
    |> validate_inclusion(:month, 1..12)
    |> assoc_constraint(:owner)
    |> unique_constraint([:month, :year, :owner_id])
  end
end
