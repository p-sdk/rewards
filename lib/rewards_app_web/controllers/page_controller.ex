defmodule RewardsAppWeb.PageController do
  use RewardsAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
