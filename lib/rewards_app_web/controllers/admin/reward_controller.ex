defmodule RewardsAppWeb.Admin.RewardController do
  use RewardsAppWeb, :controller

  alias RewardsApp.{Rewards, Users}

  def index(conn, %{"member_id" => member_id, "pool_id" => pool_id}) do
    member = Users.get_member!(member_id)
    pool = Rewards.get_pool_with_rewards_and_receivers(pool_id)

    render(conn, "index.html", member: member, pool: pool, rewards: pool.rewards)
  end
end
