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

    render conn, "searchresult.html", title: "Accueil", results: response.body, start: start
  end

  def type(conn, %{"type" => type} = params) do
    format           = type_to_format(type)
    start            = Map.get(params, "start", "0")
    {conn, response} = get_asi(conn, "search", %{"format" => format}, ["Range": format_range(start)])

    render conn, "searchresult.html", title: String.capitalize(type), results: response.body, type: type, start: start
  end

  def show(conn, %{"type" => type, "slug" => slug}) do
    {conn, response} = get_asi(conn, "contents/" <> type <> "/" <> slug)
    title            = response.body["title"]
    fetch_content    = fn slug ->
      {_, response} = get_asi(conn, "media/"<> slug)
      response
    end
    lead            = Asi.HTML.rewrite_html(response.body["lead"], fetch_content)
    content         = Asi.HTML.rewrite_html(response.body["content"], fetch_content)

    render conn, "show.html", article: response.body, title: title, lead: lead, content: content, current_url: current_url(conn)
  end

  def authors(conn, _params) do
    {conn, authors} = get_asi(conn, "authors", %{}, ["Range": "object 0-9998"])

    render conn, "authors.html", title: "Auteurs", authors: authors.body
  end

  def author(conn, %{"slug" => slug} = params) do
    start            = Map.get(params, "start", "0")
    {conn, author}   = get_asi(conn, "authors/" <> slug)
    {conn, response} = get_asi(conn, "search", %{"author" => slug}, ["Range": format_range(start)])

    render conn, "searchresult.html", title: author.body["name"], results: response.body, start: start
  end

  def themes(conn, _params) do
    {conn, response} = get_asi(conn, "themes", %{}, ["Range": "object 0-9998"])

    render conn, "themes.html", title: "Thèmes", themes: response.body
  end

  def theme(conn, %{"slug" => slug} = params) do
    start            = Map.get(params, "start", "0")
    {conn, theme}    = get_asi(conn, "themes/" <> slug)
    {conn, response} = get_asi(conn, "search", %{"theme" => slug}, ["Range": format_range(start)])

    render conn, "searchresult.html", title: theme.body["name"], results: response.body, start: start
  end

  def folders(conn, params) do
    start            = Map.get(params, "start", "0")
    {conn, response} = get_asi(conn, "dossiers", %{}, ["Range": format_range(start)])
    total            = range_to_total(response)

    render conn, "folders.html", title: "Dossiers", folders: response.body, start: start, total: total
  end

  def folder(conn, %{"slug" => slug} = params) do
    start            = Map.get(params, "start", "0")
    {conn, folder}   = get_asi(conn, "dossiers/" <> slug)
    {conn, response} = get_asi(conn, "dossiers/"<> slug <>"/contents", %{}, ["Range": format_range(start)])
    total            = range_to_total(response)

    render conn, "folder.html", title: folder.body["name"], results: response.body, start: start, folder: folder.body, total: total
  end

  def blogs(conn, params) do
    start            = Map.get(params, "start", "0")
    {conn, response} = get_asi(conn, "blogs", %{}, ["Range": format_range(start)])
    total            = range_to_total(response)

    render conn, "blogs.html", title: "Blogs", blogs: response.body, start: start, total: total
  end

  def blog(conn, %{"slug" => slug} = params) do
    start            = Map.get(params, "start", "0")
    {conn, blog}     = get_asi(conn, "blogs/" <> slug)
    {conn, response} = get_asi(conn, "blogs/"<> slug <>"/contents", %{}, ["Range": format_range(start)])
    total            = range_to_total(response)

    render conn, "blog.html", title: blog.body["title"], results: response.body, start: start, blog: blog.body, total: total
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

  def atom_themes(conn, %{"slug" => slug}) do
    {conn, response} = get_asi(conn, "search", %{"theme" => slug})

    render conn, "atom.xml", title: slug, results: response.body
  end

  def atom_authors(conn, %{"slug" => slug}) do
    {conn, response} = get_asi(conn, "search", %{"author" => slug})

    render conn, "atom.xml", title: slug, results: response.body
  end

  def format_range(start) do
    "objects "<> start <>"-"<>  Integer.to_string(String.to_integer(start) + 9)
  end

  def range_to_total(response) do
    [_, total]       = Regex.run(~r{objects [0-9]+-[0-9]+/([0-9]+)}, response.headers["content-range"])
    String.to_integer(total)
  end

  def get_user_data(conn, _) do
    logged = case get_session(conn, :access_token) do
               nil -> false
               _ -> true
             end
    assign(conn, :logged, logged)
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

    case response do
      %HTTPotion.ErrorResponse{} ->
        raise Asi.Error
      %HTTPotion.Response{} ->
        case response.status_code do
          401 ->
            conn
            |> refresh_token()
            |> get_asi(url, query, headers, retry + 1)
          404 ->
            raise Asi.NotFound
          _ ->
            {conn, response}
        end
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
end
