defmodule AsitextWeb.Router do
  use AsitextWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :atom do
    plug :accepts, ["xml"]
    plug :fetch_session
  end

  pipeline :manifest do
    plug :accepts, ["json"]
  end

  scope "/", AsitextWeb do
    pipe_through :atom

    get "/all.xml", PageController, :atom
    get "/xml/:type", PageController, :atom_type
    get "/xml/themes/:slug", PageController, :atom_themes
    get "/xml/authors/:slug", PageController, :atom_authors
  end

  scope "/", AsitextWeb do
    pipe_through :manifest

    get "/manifest.json", ManifestController, :manifest
  end

  scope "/", AsitextWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/login", PageController, :login
    post "/login", PageController, :log
    post "/logout", PageController, :logout
    get "/search", PageController, :search
    get "/authors", PageController, :authors
    get "/authors/:slug", PageController, :author
    get "/themes", PageController, :themes
    get "/themes/:slug", PageController, :theme
    get "/dossiers", PageController, :folders
    get "/dossiers/:slug", PageController, :folder

    get "/blogs", PageController, :redirect_blogs
    get "/blogs/:slug", PageController, :redirect_blog

    get "/chroniques", PageController, :chronicles
    get "/chroniques/:slug", PageController, :chronicle

    get "/:type/", PageController, :type
    get "/:type/:slug", PageController, :show
    get "/:type/:slug/comments", PageController, :comments
    get "/:type/:list/:slug", PageController, :show
    get "/:type/:list/:slug/comments", PageController, :comments
  end
end
