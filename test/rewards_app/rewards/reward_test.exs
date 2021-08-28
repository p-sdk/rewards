defmodule RewardsApp.Rewards.RewardTest do
  use RewardsApp.DataCase
  import RewardsApp.Fixtures
  alias RewardsApp.Rewards.Reward

  test "changeset/2 validates points value" do
    receiver = user_fixture()
    %{id: pool_id} = pool_fixture(%{remaining_points: 2})

    changeset =
      Reward.changeset(%Reward{}, %{points: 0, receiver_id: receiver.id, pool_id: pool_id})

    assert {"must be greater than %{number}", _} = changeset.errors[:points]

    changeset =
      Reward.changeset(%Reward{}, %{points: 1, receiver_id: receiver.id, pool_id: pool_id})

    refute changeset.errors[:points]

    changeset =
      Reward.changeset(%Reward{}, %{points: 2, receiver_id: receiver.id, pool_id: pool_id})

    refute changeset.errors[:points]

    changeset =
      Reward.changeset(%Reward{}, %{points: 3, receiver_id: receiver.id, pool_id: pool_id})

    assert {"must be less than or equal to %{number}", _} = changeset.errors[:points]
  end

  test "changeset/2 validates receiver is not sender" do
    receiver = user_fixture()
    receiver_pool = pool_fixture(%{owner_id: receiver.id})

    changeset =
      Reward.changeset(%Reward{}, %{
        points: 3,
        receiver_id: receiver.id,
        pool_id: receiver_pool.id
      })

    assert changeset.errors[:receiver_id] == {"can't be the same as sender", []}

    sender = user_fixture()
    sender_pool = pool_fixture(%{owner_id: sender.id})

    changeset =
      Reward.changeset(%Reward{}, %{points: 3, receiver_id: receiver.id, pool_id: sender_pool.id})

    refute changeset.errors[:receiver_id]
  end
end
