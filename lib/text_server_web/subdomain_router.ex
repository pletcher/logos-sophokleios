defmodule TextServerWeb.SubdomainRouter do
  use TextServerWeb, :router

  import TextServerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :put_root_layout, {TextServerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TextServerWeb.Subdomain do
    pipe_through :browser

    get "/", PageController, :index
  end
end
