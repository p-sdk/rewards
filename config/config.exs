# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :rewards_app,
  ecto_repos: [RewardsApp.Repo]

# Configures the endpoint
config :rewards_app, RewardsAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pV+MnfybFfMYrwKVLB21/yqGkkLvSmKC3mCIQ1PjsQoEMnNOtRgW8wneGpspuegW",
  render_errors: [view: RewardsAppWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RewardsApp.PubSub,
  live_view: [signing_salt: "oreIJ650"]

config :rewards_app, :pow,
  user: RewardsApp.Users.User,
  repo: RewardsApp.Repo,
  web_module: RewardsAppWeb

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :rewards_app, RewardsApp.Email,
  mail_from_address: System.get_env("MAIL_FROM_ADDRESS", "rewards@example.com")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
