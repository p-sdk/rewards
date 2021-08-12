defmodule RewardsAppWeb.Admin.PoolView do
  use RewardsAppWeb, :view

  def pool_period(pool) do
    Date.new!(pool.year, pool.month, 1)
    |> Calendar.strftime("%B %Y")
  end
end
