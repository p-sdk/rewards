defmodule RewardsAppWeb.Router do
  use RewardsAppWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :admin do
    plug RewardsAppWeb.EnsureRolePlug, :admin
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  scope "/", RewardsAppWeb do
    pipe_through [:browser, :protected]

    get "/", MemberController, :index

    resources "/members", MemberController, only: [:show] do
      resources "/rewards", RewardController, only: [:new, :create]
    end
  end

  scope "/admin", RewardsAppWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]

    scope "/members/:member_id", as: :member do
      resources "/pools", PoolController, only: [:index, :new, :create, :edit, :update] do
        resources "/rewards", RewardController, only: [:index, :new, :create, :delete]
      end
    end

    get "/reports", ReportController, :index
    get "/reports/:year/:month", ReportController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", RewardsAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: RewardsAppWeb.Telemetry
    end
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
