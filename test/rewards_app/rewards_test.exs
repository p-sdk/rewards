defmodule RewardsApp.RewardsTest do
  use RewardsApp.DataCase

  alias RewardsApp.Rewards

  describe "pools" do
    alias RewardsApp.Rewards.Pool

    @valid_attrs %{remaining_points: 30, month: 2, year: 2021}
    @update_attrs %{remaining_points: 50}
    @invalid_attrs %{month: nil, remaining_points: nil, year: nil}

    def user_fixture() do
      %RewardsApp.Users.User{
        name: "User #{System.unique_integer()}",
        email: "user#{System.unique_integer()}@example.com"
      }
      |> Repo.insert!()
    end

    def pool_fixture(attrs \\ %{}) do
      user = user_fixture()

      {:ok, pool} =
        attrs
        |> Enum.into(%{owner_id: user.id})
        |> Enum.into(@valid_attrs)
        |> Rewards.create_pool()

      pool
    end

    test "list_pools/0 returns all pools" do
      pool = pool_fixture()
      assert Rewards.list_pools() == [pool]
    end

    test "get_pool!/1 returns the pool with given id" do
      pool = pool_fixture()
      assert Rewards.get_pool!(pool.id) == pool
    end

    test "create_pool/1 with valid data creates a pool" do
      owner = user_fixture()
      attrs = Map.merge(@valid_attrs, %{owner_id: owner.id})

      assert {:ok, %Pool{} = pool} = Rewards.create_pool(attrs)
      assert pool.remaining_points == 30
      assert pool.month == 2
      assert pool.year == 2021
      assert pool.owner_id == owner.id
    end

    test "create_pool/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rewards.create_pool(@invalid_attrs)
    end

    test "update_pool/2 with valid data updates the pool" do
      pool = pool_fixture()
      assert {:ok, %Pool{} = pool} = Rewards.update_pool(pool, @update_attrs)
      assert pool.remaining_points == 50
      assert pool.month == 2
      assert pool.year == 2021
    end

    test "update_pool/2 with invalid data returns error changeset" do
      pool = pool_fixture()
      assert {:error, %Ecto.Changeset{}} = Rewards.update_pool(pool, @invalid_attrs)
      assert pool == Rewards.get_pool!(pool.id)
    end

    test "delete_pool/1 deletes the pool" do
      pool = pool_fixture()
      assert {:ok, %Pool{}} = Rewards.delete_pool(pool)
      assert_raise Ecto.NoResultsError, fn -> Rewards.get_pool!(pool.id) end
    end

    test "change_pool/1 returns a pool changeset" do
      pool = pool_fixture()
      assert %Ecto.Changeset{} = Rewards.change_pool(pool)
    end
  end

  describe "rewards" do
    alias RewardsApp.Rewards.Reward

    @valid_attrs %{points: 12}
    @update_attrs %{points: 13}
    @invalid_attrs %{points: nil}

    def reward_fixture(attrs \\ %{}) do
      pool = pool_fixture()
      receiver = user_fixture()

      {:ok, reward} =
        attrs
        |> Enum.into(%{pool_id: pool.id, receiver_id: receiver.id})
        |> Enum.into(@valid_attrs)
        |> Rewards.create_reward()

      reward
    end

    test "list_rewards/0 returns all rewards" do
      reward = reward_fixture()
      assert Rewards.list_rewards() == [reward]
    end

    test "get_reward!/1 returns the reward with given id" do
      reward = reward_fixture()
      assert Rewards.get_reward!(reward.id) == reward
    end

    test "create_reward/1 with valid data creates a reward" do
      points = 12
      pool = pool_fixture(remaining_points: 13)
      receiver = user_fixture()

      attrs = %{points: points, pool_id: pool.id, receiver_id: receiver.id}

      assert {:ok, %Reward{} = reward} = Rewards.create_reward(attrs)
      assert reward.points == 12
      assert reward.pool_id == pool.id
      assert reward.receiver_id == receiver.id
      assert Rewards.get_pool!(pool.id).remaining_points == 1
    end

    test "create_reward/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rewards.create_reward(@invalid_attrs)
    end

    test "create_reward/1 with points higher than remaining points in the pool returns error" do
      points = 12
      pool = pool_fixture(remaining_points: 11)
      receiver = user_fixture()

      attrs = %{points: points, pool_id: pool.id, receiver_id: receiver.id}

      assert {:error, :points_too_high} = Rewards.create_reward(attrs)
      assert Rewards.get_pool!(pool.id).remaining_points == 11
    end

    test "create_reward/3 associates new reward with the sender's pool for current month" do
      sender = user_fixture()
      receiver = user_fixture()
      points = 12
      now = DateTime.utc_now()
      _pool = pool_fixture(remaining_points: 20, owner_id: sender.id, month: now.month, year: now.year)

      assert {:ok, %Reward{} = reward} = Rewards.create_reward(sender, receiver, points)
      %{pool: updated_pool} = Repo.preload(reward, :pool)
      assert updated_pool.month == now.month
      assert updated_pool.year == now.year
      assert updated_pool.remaining_points == 8
    end

    test "update_reward/2 with valid data updates the reward" do
      reward = reward_fixture()
      assert {:ok, %Reward{} = reward} = Rewards.update_reward(reward, @update_attrs)
      assert reward.points == 13
    end

    test "update_reward/2 with invalid data returns error changeset" do
      reward = reward_fixture()
      assert {:error, %Ecto.Changeset{}} = Rewards.update_reward(reward, @invalid_attrs)
      assert reward == Rewards.get_reward!(reward.id)
    end

    test "delete_reward/1 deletes the reward" do
      reward = reward_fixture()
      assert {:ok, %Reward{}} = Rewards.delete_reward(reward)
      assert_raise Ecto.NoResultsError, fn -> Rewards.get_reward!(reward.id) end
    end

    test "change_reward/1 returns a reward changeset" do
      reward = reward_fixture()
      assert %Ecto.Changeset{} = Rewards.change_reward(reward)
    end
  end
end
