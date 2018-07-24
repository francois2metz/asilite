defmodule AsitextWeb.Router do
  use AsitextWeb, :router
  use Plug.ErrorHandler

  pipeline :browser do
    plug :accepts, ["html", "json"]
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
    get "/xml/chroniques/:slug", PageController, :atom_chronicles
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

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    conn = conn
    |> Plug.Conn.fetch_query_params()

    params =
    for {key, _value} = tuple <- conn.params, into: %{} do
      if key in ["password", "password_confirmation"] do
        {key, "[FILTERED]"}
      else
        tuple
      end
    end

    occurrence_data = %{
      "request" => %{
        "url" => "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}",
        "user_ip" => List.to_string(:inet.ntoa(conn.remote_ip)),
        "headers" => Enum.into(conn.req_headers, %{}),
        "method" => conn.method,
        "params" => params,
      }
    }

    Rollbax.report(kind, reason, stacktrace, _custom_data = %{}, occurrence_data)
  end
end
