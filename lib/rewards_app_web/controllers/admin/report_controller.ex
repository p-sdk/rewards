defmodule RewardsAppWeb.Admin.ReportController do
  use RewardsAppWeb, :controller
  alias RewardsApp.Rewards

  def index(conn, _params) do
    periods = Rewards.list_periods()
    render(conn, "index.html", periods: periods)
  end

  def show(conn, %{"month" => month, "year" => year}) do
    month = String.to_integer(month)
    year = String.to_integer(year)
    receivers = Rewards.get_rewards_summary(month, year)

    render(conn, "show.html", month: month, year: year, receivers: receivers)
  end
end
