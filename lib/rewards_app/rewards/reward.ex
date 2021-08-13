defmodule RewardsApp.Rewards.Reward do
  use Ecto.Schema
  import Ecto.Changeset
  alias RewardsApp.{Repo, Rewards.Pool}

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
    |> validate_points()
    |> assoc_constraint(:pool)
    |> assoc_constraint(:receiver)
    |> validate_receiver_is_not_sender()
  end

  defp validate_points(changeset) do
    pool_id = get_field(changeset, :pool_id)

    with {:is_valid, true} <- {:is_valid, changeset.valid?},
         %Pool{remaining_points: remaining_points} <- Repo.get(Pool, pool_id) do
      validate_number(changeset, :points, greater_than: 0, less_than_or_equal_to: remaining_points)
    else
      _ -> changeset
    end
  end

  defp validate_receiver_is_not_sender(changeset) do
    receiver_id = get_field(changeset, :receiver_id)
    pool_id = get_field(changeset, :pool_id)

    with {:is_valid, true} <- {:is_valid, changeset.valid?},
         %Pool{owner_id: sender_id} <- Repo.get(Pool, pool_id),
         true <- receiver_id != sender_id do
      changeset
    else
      {:is_valid, false} -> changeset
      _ -> add_error(changeset, :receiver_id, "can't be the same as sender")
    end
  end
end
