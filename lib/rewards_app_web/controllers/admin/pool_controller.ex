defmodule RewardsAppWeb.Admin.PoolController do
  use RewardsAppWeb, :controller

  alias RewardsApp.{Rewards.Pool, Rewards, Users}

  plug :assign_member

  defp assign_member(conn, _) do
    member =
      conn.params["member_id"]
      |> Users.get_member!()

    assign(conn, :member, member)
  end

  def index(conn, _params) do
    member = conn.assigns.member
    pools = Rewards.list_pools_for(member)

    render(conn, "index.html", pools: pools)
  end

  def new(conn, _params) do
    changeset = Rewards.change_pool(%Pool{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pool" => pool_params}) do
    member = conn.assigns.member
    pool_params = Map.put(pool_params, "owner_id", member.id)

    case Rewards.create_pool(pool_params) do
      {:ok, _pool} ->
        conn
        |> put_flash(:info, "Pool created successfully.")
        |> redirect(to: Routes.admin_member_pool_path(conn, :index, member))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end

    changeset = Rewards.change_pool(%Pool{})
    render(conn, "new.html", changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    pool = Rewards.get_pool!(id)
    changeset = Rewards.change_pool(pool)

    render(conn, "edit.html", pool: pool, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pool" => pool_params}) do
    member = conn.assigns.member
    pool = Rewards.get_pool!(id)

    case Rewards.update_pool(pool, pool_params) do
      {:ok, _pool} ->
        conn
        |> put_flash(:info, "Pool updated successfully.")
        |> redirect(to: Routes.admin_member_pool_path(conn, :index, member))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", pool: pool, changeset: changeset)
    end
  end
end
