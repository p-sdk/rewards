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
end
