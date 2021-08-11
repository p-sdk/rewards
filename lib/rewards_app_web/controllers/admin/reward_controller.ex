defmodule RewardsAppWeb.Admin.RewardController do
  use RewardsAppWeb, :controller

  alias RewardsApp.{Rewards.Reward, Rewards, Users}

  plug :assign_sender_and_receivers when action in [:new, :create]

  def assign_sender_and_receivers(conn, _) do
    sender_id = conn.params["member_id"]
    sender = Users.get_member!(sender_id)

    receivers =
      Users.list_members()
      |> Enum.reject(fn m -> m.id == sender.id end)

    conn
    |> assign(:sender, sender)
    |> assign(:receivers, receivers)
  end

  def index(conn, %{"member_id" => member_id, "pool_id" => pool_id}) do
    member = Users.get_member!(member_id)
    pool = Rewards.get_pool_with_rewards_and_receivers(pool_id)

    render(conn, "index.html", member: member, pool: pool, rewards: pool.rewards)
  end

  def new(conn, %{"pool_id" => pool_id}) do
    pool = Rewards.get_pool!(pool_id)
    changeset = Rewards.change_reward(%Reward{})

    render(conn, "new.html", pool: pool, changeset: changeset)
  end

  def create(conn, %{"pool_id" => pool_id, "reward" => reward_params}) do
    pool = Rewards.get_pool!(pool_id)
    reward_params = Map.put(reward_params, "pool_id", pool_id)

    case Rewards.create_reward(reward_params) do
      {:ok, _reward} ->
        conn
        |> put_flash(:info, "Reward created successfully.")
        |> redirect(to: Routes.admin_member_pool_reward_path(conn, :index, conn.assigns.sender.id, pool_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", pool: pool, changeset: changeset)

      {:error, :points_too_high} ->
        changeset = Rewards.change_reward(%Reward{})

        conn
        |> put_flash(:error, "The requested amount of points to reward is too high.")
        |> render("new.html", pool: pool, changeset: changeset)
    end
  end

  def delete(conn, %{"member_id" => member_id, "pool_id" => pool_id, "id" => id}) do
    reward = Rewards.get_reward!(id)
    {:ok, _reward} = Rewards.delete_reward(reward)

    conn
    |> put_flash(:info, "Reward deleted successfully.")
    |> redirect(to: Routes.admin_member_pool_reward_path(conn, :index, member_id, pool_id))
  end
end
