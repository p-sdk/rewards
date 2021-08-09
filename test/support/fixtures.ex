defmodule RewardsApp.Fixtures do
  alias RewardsApp.Repo
  alias RewardsApp.Users.User

  def user_fixture() do
    %User{
      name: "Member #{System.unique_integer()}",
      email: "member#{System.unique_integer()}@example.com"
    }
    |> Repo.insert!()
  end
end
