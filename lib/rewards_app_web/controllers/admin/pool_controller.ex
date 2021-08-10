defmodule RewardsAppWeb.Admin.PoolController do
  use RewardsAppWeb, :controller

  alias RewardsApp.{Rewards, Users}

  def edit(conn, %{"member_id" => member_id, "id" => id}) do
    member = Users.get_member!(member_id)
    pool = Rewards.get_pool!(id)
    changeset = Rewards.change_pool(pool)

    render(conn, "edit.html", member: member, pool: pool, changeset: changeset)
  end

  def update(conn, %{"member_id" => member_id, "id" => id, "pool" => pool_params}) do
    member = Users.get_member!(member_id)
    pool = Rewards.get_pool!(id)

    case Rewards.update_pool(pool, pool_params) do
      {:ok, _pool} ->
        conn
        |> put_flash(:info, "Pool updated successfully.")
        |> redirect(to: Routes.admin_member_path(conn, :show, member))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", member: member, pool: pool, changeset: changeset)
    end
  end
end
