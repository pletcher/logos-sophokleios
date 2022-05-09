defmodule TextServerWeb.Router do
  use TextServerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TextServerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TextServerWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/authors", AuthorLive.Index, :index
    live "/authors/new", AuthorLive.Index, :new
    live "/authors/:id/edit", AuthorLive.Index, :edit

    live "/authors/:id", AuthorLive.Show, :show
    live "/authors/:id/show/edit", AuthorLive.Show, :edit

    live "/collections", CollectionLive.Index, :index
    live "/collections/new", CollectionLive.Index, :new
    live "/collections/:id/edit", CollectionLive.Index, :edit

    live "/collections/:id", CollectionLive.Show, :show
    live "/collections/:id/show/edit", CollectionLive.Show, :edit

    live "/languages", LanguageLive.Index, :index
    live "/languages/new", LanguageLive.Index, :new
    live "/languages/:id/edit", LanguageLive.Index, :edit

    live "/languages/:id", LanguageLive.Show, :show
    live "/languages/:id/show/edit", LanguageLive.Show, :edit

    live "/refs_decls", RefsDeclLive.Index, :index
    live "/refs_decls/new", RefsDeclLive.Index, :new
    live "/refs_decls/:id/edit", RefsDeclLive.Index, :edit

    live "/refs_decls/:id", RefsDeclLive.Show, :show
    live "/refs_decls/:id/show/edit", RefsDeclLive.Show, :edit

    live "/text_groups", TextGroupLive.Index, :index
    live "/text_groups/new", TextGroupLive.Index, :new
    live "/text_groups/:id/edit", TextGroupLive.Index, :edit

    live "/text_groups/:id", TextGroupLive.Show, :show
    live "/text_groups/:id/show/edit", TextGroupLive.Show, :edit

    live "/text_nodes", TextNodeLive.Index, :index
    live "/text_nodes/new", TextNodeLive.Index, :new
    live "/text_nodes/:id/edit", TextNodeLive.Index, :edit

    live "/text_nodes/:id", TextNodeLive.Show, :show
    live "/text_nodes/:id/show/edit", TextNodeLive.Show, :edit

    live "/translations", TranslationLive.Index, :index
    live "/translations/new", TranslationLive.Index, :new
    live "/translations/:id/edit", TranslationLive.Index, :edit

    live "/translations/:id", TranslationLive.Show, :show
    live "/translations/:id/show/edit", TranslationLive.Show, :edit

    live "/versions", VersionLive.Index, :index
    live "/versions/new", VersionLive.Index, :new
    live "/versions/:id/edit", VersionLive.Index, :edit

    live "/versions/:id", VersionLive.Show, :show
    live "/versions/:id/show/edit", VersionLive.Show, :edit

    live "/works", WorkLive.Index, :index
    live "/works/new", WorkLive.Index, :new
    live "/works/:id/edit", WorkLive.Index, :edit

    live "/works/:id", WorkLive.Show, :show
    live "/works/:id/show/edit", WorkLive.Show, :edit
  end

  scope "/graphql" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: TextServerWeb.Schema

    forward "/", Absinthe.Plug,
      schema: TextServerWeb.Schema
  end

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

      live_dashboard "/dashboard", metrics: TextServerWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
