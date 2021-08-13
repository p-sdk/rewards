defmodule RewardsApp.Fixtures do
  alias RewardsApp.Repo
  alias RewardsApp.Rewards
  alias RewardsApp.Users.User

  def pool_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, pool} =
      attrs
      |> Enum.into(%{owner_id: user.id, remaining_points: 30, month: 2, year: 2021})
      |> Rewards.create_pool()

    pool
  end

  def user_fixture() do
    %User{
      name: "Member #{System.unique_integer()}",
      email: "member#{System.unique_integer()}@example.com"
    }
    |> Repo.insert!()
  end
end
