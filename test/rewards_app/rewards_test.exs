defmodule RewardsApp.RewardsTest do
  use RewardsApp.DataCase
  import RewardsApp.Fixtures
  alias RewardsApp.Rewards

  describe "pools" do
    alias RewardsApp.Rewards.Pool

    @valid_attrs %{remaining_points: 30, month: 2, year: 2021}
    @update_attrs %{remaining_points: 50}
    @invalid_attrs %{month: nil, remaining_points: nil, year: nil}

    def pool_fixture(attrs \\ %{}) do
      user = user_fixture()

      {:ok, pool} =
        attrs
        |> Enum.into(%{owner_id: user.id})
        |> Enum.into(@valid_attrs)
        |> Rewards.create_pool()

      pool
    end

    test "list_periods/0" do
      member = user_fixture()
      other_member = user_fixture()
      %Pool{} = pool_fixture(owner_id: member.id, month: 1, year: 2004)
      %Pool{} = pool_fixture(owner_id: other_member.id, month: 1, year: 2004)
      %Pool{} = pool_fixture(owner_id: member.id, month: 2, year: 2004)

      assert [%{month: 2, year: 2004}, %{month: 1, year: 2004}] = Rewards.list_periods()
    end

    test "list_pools/0 returns all pools" do
      pool = pool_fixture()
      assert Rewards.list_pools() == [pool]
    end

    test "list_pools_for/1 returns pools owned by the given member" do
      member = user_fixture()
      other_member = user_fixture()
      pool_1 = pool_fixture(owner_id: member.id, month: 1)
      _pool_2 = pool_fixture(owner_id: other_member.id, month: 2)
      pool_3 = pool_fixture(owner_id: member.id, month: 3)

      assert Rewards.list_pools_for(member) == [pool_3, pool_1]
    end

    test "get_pool!/1 returns the pool with given id" do
      pool = pool_fixture()
      assert Rewards.get_pool!(pool.id) == pool
    end

    test "get_or_create_pool_for/3" do
      owner = user_fixture()
      owner_id = owner.id
      month = 5
      year = 2020

      assert %Pool{
               owner_id: ^owner_id,
               month: ^month,
               year: ^year,
               id: id
             } = Rewards.get_or_create_pool_for(owner, month, year)

      assert %Pool{
               owner_id: ^owner_id,
               month: ^month,
               year: ^year,
               id: ^id
             } = Rewards.get_or_create_pool_for(owner, month, year)
    end

    test "get_pool_with_rewards_and_receivers/1 returns the pool with preloaded rewards and receivers" do
      pool = pool_fixture()
      %{id: reward_1_id, receiver_id: reward_1_receiver_id} = reward_fixture(%{pool_id: pool.id})
      %{id: reward_2_id} = reward_fixture(%{pool_id: pool.id})

      assert %Pool{rewards: [reward_2, reward_1]} =
               Rewards.get_pool_with_rewards_and_receivers(pool.id)

      assert reward_1.id == reward_1_id
      assert reward_2.id == reward_2_id
      assert reward_1.receiver.id == reward_1_receiver_id
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

    test "list_rewards_given_by/1 returns rewards given by the given member" do
      sender = user_fixture()
      other_sender = user_fixture()
      receiver_1 = user_fixture()
      receiver_2 = user_fixture()
      {:ok, %{id: reward_1_id}} = Rewards.create_reward(sender, receiver_1, 3)
      {:ok, %{id: _reward_2_id}} = Rewards.create_reward(other_sender, receiver_1, 4)
      {:ok, %{id: reward_3_id}} = Rewards.create_reward(sender, receiver_2, 5)

      assert [
               %{id: ^reward_3_id, receiver: ^receiver_2, points: 5},
               %{id: ^reward_1_id, receiver: ^receiver_1, points: 3}
             ] = Rewards.list_rewards_given_by(sender)
    end

    test "get_rewards_summary/2" do
      sender = user_fixture()
      other_sender = user_fixture()
      receiver_1 = user_fixture()
      receiver_2 = user_fixture()
      {:ok, _} = Rewards.create_reward(sender, receiver_1, 3)
      {:ok, _} = Rewards.create_reward(other_sender, receiver_1, 4)
      {:ok, _} = Rewards.create_reward(sender, receiver_2, 5)
      {:ok, _} = Rewards.create_reward(sender, receiver_2, 6)
      {:ok, _} = Rewards.create_reward(other_sender, receiver_1, 7)

      now = DateTime.utc_now()

      assert Rewards.get_rewards_summary(now.month, now.year) == [
               %{name: receiver_1.name, points: 14},
               %{name: receiver_2.name, points: 11}
             ]
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
      pool = pool_fixture(remaining_points: 18)
      reward = reward_fixture(points: 3, pool_id: pool.id)
      15 = Rewards.get_pool!(pool.id).remaining_points

      assert {:ok, %Reward{}} = Rewards.delete_reward(reward)
      assert Rewards.get_pool!(pool.id).remaining_points == 18

      assert_raise Ecto.NoResultsError, fn -> Rewards.get_reward!(reward.id) end
    end

    test "change_reward/1 returns a reward changeset" do
      reward = reward_fixture()
      assert %Ecto.Changeset{} = Rewards.change_reward(reward)
    end
  end
end
