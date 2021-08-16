defmodule RewardsAppWeb.Admin.PoolView do
  use RewardsAppWeb, :view

  @months [
    {"January", "1"},
    {"February", "2"},
    {"March", "3"},
    {"April", "4"},
    {"May", "5"},
    {"June", "6"},
    {"July", "7"},
    {"August", "8"},
    {"September", "9"},
    {"October", "10"},
    {"November", "11"},
    {"December", "12"}
  ]

  def month_options() do
    @months
  end

  def pool_period(pool) do
    format_period(%{month: pool.month, year: pool.year})
  end

  def format_period(%{month: month, year: year}) do
    Date.new!(year, month, 1)
    |> Calendar.strftime("%B %Y")
  end
end
