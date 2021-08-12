defmodule RewardsAppWeb.Admin.PoolViewTest do
  use RewardsAppWeb.ConnCase, async: true
  alias RewardsApp.Rewards.Pool

  test "pool_period" do
    pool = %Pool{month: 4, year: 2021}

    assert RewardsAppWeb.Admin.PoolView.pool_period(pool) == "April 2021"
  end
end
