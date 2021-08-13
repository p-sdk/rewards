defmodule RewardsApp.Rewards.RewardTest do
  use RewardsApp.DataCase
  import RewardsApp.Fixtures
  alias RewardsApp.Rewards.Reward

  test "changeset/2 validates receiver is not sender" do
    receiver = user_fixture()
    receiver_pool = pool_fixture(%{owner_id: receiver.id})
    changeset = Reward.changeset(%Reward{}, %{points: 3, receiver_id: receiver.id, pool_id: receiver_pool.id})

    assert changeset.errors[:receiver_id] == {"can't be the same as sender", []}

    sender = user_fixture()
    sender_pool = pool_fixture(%{owner_id: sender.id})
    changeset = Reward.changeset(%Reward{}, %{points: 3, receiver_id: receiver.id, pool_id: sender_pool.id})

    refute changeset.errors[:receiver_id]
  end
end
