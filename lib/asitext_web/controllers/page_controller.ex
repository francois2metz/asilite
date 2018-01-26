defmodule AsitextWeb.PageController do
  use AsitextWeb, :controller

  if Application.get_env(:asitext, :basic_auth) do
    plug BasicAuth, [use_config: {:asitext, :basic_auth}] when action in [:login, :log]
  end

  plug :get_user_data
  plug :set_csp

  def index(conn, params) do
    start            = Map.get(params, "start", "0")
    {conn, response} = get_asi(conn, "search", %{}, ["Range": format_range(start)])

    render conn, "index.html", title: "Accueil", results: response.body, start: start
  end

  def type(conn, %{"type" => type} = params) do
    format           = type_to_format(type)
    start            = Map.get(params, "start", "0")
    {conn, response} = get_asi(conn, "search", %{"format" => format}, ["Range": format_range(start)])

    render conn, "type.html", title: String.capitalize(type), results: response.body, type: type, start: start
  end

  def show(conn, %{"type" => type, "slug" => slug}) do
    {conn, response} = get_asi(conn, "contents/" <> type <> "/" <> slug)
    title            = response.body["title"]

    render conn, "show.html", article: response.body, title: title, type: type, content: rewrite_html(response.body["content"])
  end

  def login(conn, _params) do
    render conn, "login.html", title: "Connexion"
  end

  def log(conn, params) do
    result = Asi.get_token(params)

    case result.status_code do
      200 ->
        body = Poison.decode!(result.body)
        conn
        |> put_session(:access_token, body["access_token"])
        |> put_session(:refresh_token, body["refresh_token"])
        |> put_flash(:info, "Vous êtes connecté!")
        |> redirect(to: page_path(conn, :index))
      _ ->
        conn
        |> put_flash(:error, "Connexion impossible")
        |> redirect(to: page_path(conn, :login))
    end
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "Vous êtes déconnecté")
    |> delete_session(:access_token)
    |> delete_session(:refresh_token)
    |> redirect(to: page_path(conn, :index))
  end

  def search(conn, %{"q" => q} = params) do
    start            = Map.get(params, "start", "0")
    {conn, response} = get_asi(conn, "search", %{"q" => q}, ["Range": format_range(start)])

    render conn, "search.html", title: "Search "<> q, results: response.body, start: start, q: q
  end

  def atom(conn, _params) do
    {conn, response} = get_asi(conn, "search")

    render conn, "atom.xml", title: "Tout les contenus", results: response.body
  end

  def atom_type(conn, %{"type" => type}) do
    format           = type_to_format(type)
    {conn, response} = get_asi(conn, "search", %{"format" => format})

    render conn, "atom.xml", title: String.capitalize(type), results: response.body
  end

  def format_range(start) do
    "objects "<> start <>" "<>  Integer.to_string(String.to_integer(start) + 10)
  end

  def get_user_data(conn, _) do
    case get_session(conn, :access_token) do
      nil ->
        assign(conn, :logged, false)
      _ ->
        assign(conn, :logged, true)
    end
  end

  def set_csp(conn, _) do
    [nonce] = get_resp_header(conn, "x-request-id")
    conn
    |> put_resp_header("Content-Security-Policy", "script-src 'self' https://www.google-analytics.com/ 'nonce-"<> nonce <>"';")
    |> assign(:nonce, nonce)
  end

  def type_to_format(type) do
    case type do
      "chroniques" -> "chronique"
      "articles"   -> "article"
      "emissions"  -> "emission"
    end
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
    response = Asi.get(url, query: set_query_params(conn, query), headers: headers)

    case response.status_code do
      401 ->
        conn
        |> refresh_token()
        |> get_asi(url, query, headers, retry + 1)
      _ ->
        {conn, response}
    end
  end

  def refresh_token(conn) do
    response = Asi.refresh_token(get_session(conn, :access_token), get_session(conn, :refresh_token))
    case response.status_code do
      200 ->
        body = Poison.decode!(response.body)
        conn
        |> put_session(:access_token, body["access_token"])
        |> put_session(:refresh_token, body["refresh_token"])
      _ ->
        conn
        |> put_flash(:error, "La session a expiré")
        |> delete_session(:access_token)
        |> delete_session(:refresh_token)
    end
  end

  def set_query_params(conn, query) do
    access_token = get_session(conn, :access_token)
    case access_token do
      nil -> query
      _ -> Map.put(query, "access_token", access_token)
    end
  end

  def rewrite_html(html) do
    html
    |> Floki.parse()
    |> rewrite_links()
    |> rewrite_tags()
    |> Floki.raw_html()
  end

  def rewrite_links(html) do
    html
    |> Floki.attr("a", "href", fn(href) ->
      href
      |> String.replace(~r/^\/([^\/]+)\/[0-9-]+\/(.+)/, "/\\1/\\2")
      |> String.replace(~r/https:\/\/beta.arretsurimages.net\/([^\/]+)\/[0-9-]+\/(.+)/, "/\\1/\\2")
      |> String.replace(~r/https:\/\/beta.arretsurimages.net\/([^\/]+)\/([^\/]+)/, "/\\1/\\2")
    end)
  end

  def rewrite_tags(html) do
    html
    |> Floki.map(fn({name, attributes}) ->
      class = :proplists.get_value("class", attributes)
      attributes = :proplists.delete("class", attributes)
      case name do
        "asi-image" -> {"div", [{"class", "image "<> class}|attributes]}
        "asi-encadre" -> {"div", [{"class", "encadre "<> class}|attributes]}
        _ -> {name, attributes}
      end
    end)
  end
end
