defmodule RewardsApp.Repo do
  use Ecto.Repo,
    otp_app: :rewards_app,
    adapter: Ecto.Adapters.Postgres
end
