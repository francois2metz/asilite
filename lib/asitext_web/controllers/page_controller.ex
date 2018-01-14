defmodule AsitextWeb.PageController do
  use AsitextWeb, :controller

  def index(conn, _params) do
    results = get_asi(conn, "search").body
    render conn, "index.html", title: "Accueil", results: results
  end

  def type(conn, %{"type" => type}) do
    results = get_asi(conn, "search", "format=" <> type).body
    render conn, "type.html", title: type, results: results, type: type
  end

  def show(conn, %{"type" => type, "slug" => slug}) do
    article = get_asi(conn, "contents/" <> type <> "/" <> slug).body
    title   = article["title"]
    render conn, "show.html", article: article, title: title
  end

  def login(conn, _params) do
    render conn, "login.html", title: "Login"
  end

  def log(conn, params) do
    result = Asi.get_token(params)

    case result.status_code do
      200 ->
        body = Poison.decode!(result.body)
        put_session(conn, :access_token, body["access_token"]) |>
          put_session(:refresh_token, body["refresh_token"]) |>
          put_session(:token_type, body["token_type"]) |>
          put_session(:expires_in, body["expires_in"]) |>
          put_flash(:info, "Logged in!") |>
          redirect to: page_path(conn, :index)
      _ ->
        put_flash(conn, :error, "Could not connect") |>
          redirect to: page_path(conn, :login)
    end
  end

  def get_asi(conn, path) do
    get_asi(conn, path, "")
  end

  def get_asi(conn, path, query) do
    access_token = get_session(conn, :access_token)
    url = case access_token do
            nil ->
              path
            _ ->
              path <>"?"<> query <>"&access_token=" <> access_token
          end
    Asi.get(url)
  end
end
