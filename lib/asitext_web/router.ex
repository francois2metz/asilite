defmodule AsitextWeb.Router do
  use AsitextWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    if Application.get_env(:asitext, :basic_auth) do
      plug BasicAuth, use_config: {:asitext, :basic_auth}
    end
  end

  pipeline :atom do
    plug :accepts, ["xml"]
    plug :fetch_session
  end

  scope "/", AsitextWeb do
    pipe_through :atom

    get "/all.xml", PageController, :atom
    get "/xml/:type", PageController, :atom_type
  end

  scope "/", AsitextWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/login", PageController, :login
    post "/login", PageController, :log
    get "/search", PageController, :search
    get "/:type/", PageController, :type
    get "/:type/:slug", PageController, :show
  end
end
