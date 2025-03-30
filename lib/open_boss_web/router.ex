defmodule OpenBossWeb.Router do
  use OpenBossWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OpenBossWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OpenBossWeb do
    pipe_through :browser

    live "/", ActiveCookLive.Home, :home

    live "/devices", DevicesLive.Index, :index
    live "/devices/:id/edit", DevicesLive.Index, :edit
    live "/devices/:id", DevicesLive.Show, :show
    live "/devices/:id/show/edit", DevicesLive.Show, :edit

    live "/cooks", CookLive.Index, :index
    live "/cooks/new", CookLive.Index, :new
    live "/cooks/:id/edit", CookLive.Index, :edit
    live "/cooks/:id", CookLive.Show, :show
    live "/cooks/:id/show/edit", CookLive.Show, :edit
    live "/cooks/:id/history", CookLive.History, :history

    live "/network", NetworkLive.Index, :index
    live "/network/:id", NetworkLive.Show, :show
    live "/network/:id/edit", NetworkLive.Index, :edit
    live "/network/:id/show/edit", NetworkLive.Show, :edit
    live "/network/:id/show/edit_wifi", NetworkLive.Show, :edit_wifi

    live "/display", DisplayLive.Index, :index
    live "/display/:id/edit", DisplayLive.Index, :edit
    live "/display/:id", DisplayLive.Show, :show
    live "/display/:id/show/edit", DisplayLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", OpenBossWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:open_boss, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OpenBossWeb.Telemetry, ecto_repos: [OpenBoss.Repo]
    end
  end
end
