defmodule RewardsAppWeb.Admin.ReportView do
  use RewardsAppWeb, :view

  def format_period(%{month: month, year: year}) do
    Date.new!(year, month, 1)
    |> Calendar.strftime("%B %Y")
  end
end
