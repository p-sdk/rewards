defmodule RewardsAppWeb.RewardController do
  use RewardsAppWeb, :controller

  alias RewardsApp.{Rewards, Users}
  alias RewardsApp.Rewards.Reward

  plug :assign_current_pool_remaining_points when action in [:new, :create]

  def new(conn, %{"member_id" => id}) do
    member = Users.get_member!(id)
    changeset = Rewards.change_reward(%Reward{})

    render(conn, "new.html", member: member, changeset: changeset)
  end

  def create(conn, %{"member_id" => member_id, "reward" => %{"points" => points}}) do
    member = Users.get_member!(member_id)

    case Rewards.create_reward(conn.assigns.current_user, member, points) do
      {:ok, _reward} ->
        conn
        |> put_flash(:info, "Reward created successfully.")
        |> redirect(to: Routes.member_path(conn, :show, conn.assigns.current_user))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("new.html", member: member, changeset: changeset)

      {:error, :points_too_high} ->
        changeset = Rewards.change_reward(%Reward{})

        conn
        |> put_flash(:error, "The requested amount of points to reward is too high.")
        |> render("new.html", member: member, changeset: changeset)
    end
  end
end
