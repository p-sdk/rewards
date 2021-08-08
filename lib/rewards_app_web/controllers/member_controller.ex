defmodule RewardsAppWeb.MemberController do
  use RewardsAppWeb, :controller

  alias RewardsApp.Rewards
  alias RewardsApp.Rewards.Reward

  def show(conn, %{"id" => id}) do
    member = Rewards.get_member!(id)
    changeset = Rewards.change_reward(%Reward{})
    render(conn, "show.html", member: member, changeset: changeset)
  end
end
