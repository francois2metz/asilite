defmodule AsitextWeb.PageController do
  use AsitextWeb, :controller

  def index(conn, params) do
    start             = Map.get(params, "start", "0")
    {conn2, response} = get_asi(conn, "search", %{}, ["Range": format_range(start)])

    render conn2, "index.html", title: "Accueil", results: response.body, start: start
  end

  def type(conn, %{"type" => type} = params) do
    start             = Map.get(params, "start", "0")
    {conn2, response} = get_asi(conn, "search", %{"format" => type}, ["Range": format_range(start)])
    render conn2, "type.html", title: type, results: response.body, type: type, start: start
  end

  def show(conn, %{"type" => type, "slug" => slug}) do
    {conn2, response} = get_asi(conn, "contents/" <> type <> "/" <> slug)
    title             = response.body["title"]
    render conn2, "show.html", article: response.body, title: title
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
          put_flash(:info, "Logged in!") |>
          redirect(to: page_path(conn, :index))
      _ ->
        put_flash(conn, :error, "Could not connect") |>
          redirect(to: page_path(conn, :login))
    end
  end

  def format_range(start) do
    "objects "<> start <>" "<>  Integer.to_string(String.to_integer(start) + 10)
  end

  def get_asi(conn, path) do
    get_asi(conn, path, %{})
  end

  def get_asi(conn, path, query) do
    get_asi(conn, path, query, [])
  end

  def get_asi(conn, url, query, headers) do
    get_asi(conn, url, query, headers, 0)
  end

  def get_asi(_conn, _url, _query, _headers, 2) do
    raise "oops"
  end

  def get_asi(conn, url, query, headers, retry) do
    access_token = get_session(conn, :access_token)
    query2 = case access_token do
               nil ->
                 query
               _ ->
                 Map.put(query, "access_token", access_token)
             end
    response = Asi.get(url, query: query2, headers: headers)

    case response.status_code do
      401 ->
        result = Asi.refresh_token(access_token, get_session(conn, :refresh_token))
        case result.status_code do
          200 ->
            body = Poison.decode!(result.body)
            put_session(conn, :access_token, body["access_token"]) |>
              put_session(:refresh_token, body["refresh_token"]) |>
              get_asi(url, query, headers, retry + 1)
          _ ->
            {put_flash(conn, :error, "Could not connect"), response}
        end
      200 ->
        {conn, response}
      206 ->
        {conn, response}
    end
  end
end
