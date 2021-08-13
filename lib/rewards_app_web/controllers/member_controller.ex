defmodule RewardsAppWeb.MemberController do
  use RewardsAppWeb, :controller

  alias RewardsApp.{Rewards, Users}

  def index(conn, _params) do
    members = Users.list_members()
    render(conn, "index.html", members: members)
  end

  def show(conn, %{"id" => id}) do
    member = Users.get_member!(id)
    given_rewards = Rewards.list_rewards_given_by(member)

    render(conn, "show.html", member: member, given_rewards: given_rewards)
  end
end
