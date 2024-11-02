defmodule IotDashboardWeb.Router do
  use IotDashboardWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {IotDashboardWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IotDashboardWeb do
    pipe_through :browser

    live "/dashboard", DashboardLive
    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", IotDashboardWeb do
  #   pipe_through :api
  # end
end
