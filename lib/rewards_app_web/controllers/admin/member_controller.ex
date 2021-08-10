defmodule RewardsAppWeb.Admin.MemberController do
  use RewardsAppWeb, :controller

  alias RewardsApp.{Rewards, Users}

  def show(conn, %{"id" => id}) do
    member = Users.get_member!(id)
    pools = Rewards.list_pools_for(member)

    render(conn, "show.html", member: member, pools: pools)
  end
end
