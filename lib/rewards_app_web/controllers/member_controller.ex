defmodule RewardsAppWeb.MemberController do
  use RewardsAppWeb, :controller

  alias RewardsApp.{Rewards, Users}
  alias RewardsApp.Rewards.Reward

  plug :assign_current_pool_remaining_points when action in [:show]

  def index(conn, _params) do
    members = Users.list_members()
    render(conn, "index.html", members: members)
  end

  def show(conn, %{"id" => id}) do
    member = Users.get_member!(id)

    if conn.assigns.current_user == member do
      given_rewards = Rewards.list_rewards_given_by(member)

      render(conn, "show.html", member: member, given_rewards: given_rewards)
    else
      changeset = Rewards.change_reward(%Reward{})

      render(conn, "show.html", member: member, changeset: changeset)
    end
  end
end
