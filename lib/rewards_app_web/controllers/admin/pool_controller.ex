defmodule RewardsAppWeb.Admin.PoolController do
  use RewardsAppWeb, :controller

  alias RewardsApp.{Rewards.Pool, Rewards, Users}

  def index(conn, %{"member_id" => id}) do
    member = Users.get_member!(id)
    pools = Rewards.list_pools_for(member)

    render(conn, "index.html", member: member, pools: pools)
  end

  def new(conn, %{"member_id" => member_id}) do
    member = Users.get_member!(member_id)
    changeset = Rewards.change_pool(%Pool{})
    render(conn, "new.html", member: member, changeset: changeset)
  end

  def create(conn, %{"member_id" => member_id, "pool" => pool_params}) do
    member = Users.get_member!(member_id)
    pool_params = Map.put(pool_params, "owner_id", member_id)

    case Rewards.create_pool(pool_params) do
      {:ok, _pool} ->
        conn
        |> put_flash(:info, "Pool created successfully.")
        |> redirect(to: Routes.admin_member_pool_path(conn, :index, member))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", member: member, changeset: changeset)
    end

    changeset = Rewards.change_pool(%Pool{})
    render(conn, "new.html", member: member, changeset: changeset)
  end

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
        |> redirect(to: Routes.admin_member_pool_path(conn, :index, member))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", member: member, pool: pool, changeset: changeset)
    end
  end
end
