defmodule RewardsAppWeb.Plugs do
  import Plug.Conn
  alias RewardsApp.Rewards

  def assign_current_pool_remaining_points(conn, _) do
    remaining_points =
      Rewards.get_or_create_current_pool_for(conn.assigns.current_user).remaining_points

    assign(conn, :remaining_points, remaining_points)
  end
end
