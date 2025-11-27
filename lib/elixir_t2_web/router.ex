defmodule ElixirT2Web.Router do
  use ElixirT2Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ElixirT2Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirT2Web do
    pipe_through :browser

    get "/", PageController, :home
    get "/page1", PageController, :page1
    get "/page2", PageController, :page2
    get "/page3", PageController, :page3
    get "/article", PageController, :article
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirT2Web do
  #   pipe_through :api
  # end
end
