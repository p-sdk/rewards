defmodule RewardsAppWeb.Admin.RewardController do
  use RewardsAppWeb, :controller

  alias RewardsApp.{Rewards, Users}

  def index(conn, %{"member_id" => member_id, "pool_id" => pool_id}) do
    member = Users.get_member!(member_id)
    pool = Rewards.get_pool_with_rewards_and_receivers(pool_id)

    render(conn, "index.html", member: member, pool: pool, rewards: pool.rewards)
  end

  def delete(conn, %{"member_id" => member_id, "pool_id" => pool_id, "id" => id}) do
    reward = Rewards.get_reward!(id)
    {:ok, _reward} = Rewards.delete_reward(reward)

    conn
    |> put_flash(:info, "Reward deleted successfully.")
    |> redirect(to: Routes.admin_member_pool_reward_path(conn, :index, member_id, pool_id))
  end
end
