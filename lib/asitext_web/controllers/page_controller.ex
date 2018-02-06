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
    lead            = rewrite_html(response.body["lead"], fetch_content)
    content         = rewrite_html(response.body["content"], fetch_content)

    render conn, "show.html", article: response.body, title: title, type: type, lead: lead, content: content, current_url: current_url(conn)
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
    [_, total]       = Regex.run(~r{objects [0-9]+-[0-9]+/([0-9]+)}, response.headers["content-range"])

    render conn, "folders.html", title: "Dossiers", folders: response.body, start: start, total: total
  end

  def folder(conn, %{"slug" => slug} = params) do
    start            = Map.get(params, "start", "0")
    {conn, folder}   = get_asi(conn, "dossiers/" <> slug)
    {conn, response} = get_asi(conn, "dossiers/"<> slug <>"/contents", %{}, ["Range": format_range(start)])
    [_, total]       = Regex.run(~r{objects [0-9]+-[0-9]+/([0-9]+)}, response.headers["content-range"])

    render conn, "folder.html", title: folder.body["name"], results: response.body, start: start, folder: folder.body, total: total
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
    "objects "<> start <>"-"<>  Integer.to_string(String.to_integer(start) + 9)
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

    case response.status_code do
      401 ->
        conn
        |> refresh_token()
        |> get_asi(url, query, headers, retry + 1)
      404 ->
        raise Asi.NotFound
      200 ->
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

  def rewrite_html(html, fetch_content) do
    html
    |> Floki.parse()
    |> rewrite_tags(fetch_content)
    |> Floki.raw_html()
  end

  defp rewrite_tags(html, fetch_content) do
    html
    |> map(&rewrite_tag(&1, fetch_content))
  end

  defp rewrite_tag({"a", attributes, rest}, _) do
    {attributes, href} = without_key(attributes, "href")

    {"a", [{"href", rewrite_href(href)} | :proplists.delete("target", attributes)], rest}
  end

  defp rewrite_tag({"asi-image", attributes, _rest}, _) do
    {attributes, slug} = without_key(attributes, "slug")
    {attributes, class} = without_key(attributes, "class")

    {
      "div",
      [{"class", "image "<> class} | attributes],
      [
        {
          "img",
          [
            {"src", "https://api.arretsurimages.net/api/public/media/"<> slug <>"/action/show?format=public"},
            {"alt", ""}
          ],
          []
        }
      ]
    }
  end

  defp rewrite_tag({"asi-encadre", attributes, rest}, _) do
    {attributes, class} = without_key(attributes, "class")
    {"div", [{"class", "encadre "<> class} | attributes], rest}
  end

  defp rewrite_tag({"asi-citation", attributes, rest}, _) do
    {attributes, class} = without_key(attributes, "class")
    {"div", [{"class", "citation "<> class} | attributes], rest}
  end

  defp rewrite_tag({"asi-video", attributes, _rest}, fetch_content) do
    {attributes, slug} = without_key(attributes, "slug")
    response = fetch_content.(slug)
    embed_url = response.body["metas"]["embed_url"]
    {
      "div",
      [{"class", "embed-responsive embed-responsive-16by9"}],
      [
        {
          "iframe",
          [
            {"src", embed_url},
            {"allowfullscreen", "true"}
            | attributes
          ],
          []
        }
      ]
    }
  end

  defp rewrite_tag(other, _) do
    other
  end

  defp rewrite_href(href) do
    href
    |> String.replace(~r/^\/([^\/]+)\/[0-9-]+\/(.+)/, "/\\1/\\2")
    |> String.replace(~r/^\/([^\/]+)\/(.+)-id[0-9]+/, "/\\1/\\2")
    |> String.replace(~r/https:\/\/beta.arretsurimages.net\/([^\/]+)\/[0-9-]+\/(.+)/, "/\\1/\\2")
    |> String.replace(~r/https:\/\/beta.arretsurimages.net\/([^\/]+)\/([^\/]+)/, "/\\1/\\2")
    |> String.replace(~r/^\/breves\/(.+)/, "/articles/\\1")
    |> String.replace(~r/-l-([a-zA-Z]+)/, "-l\\1")
    |> String.replace(~r/-d-([a-zA-Z]+)/, "-d\\1")
    |> String.replace(~r/-n-([a-zA-Z]+)/, "-n\\1")
    |> String.replace(~r/-qu-([a-zA-Z]+)/, "-qu\\1")
  end

  defp without_key(list, key) do
    value = :proplists.get_value(key, list, "")
    list = :proplists.delete(key, list)
    {list, value}
  end

  def map(html, fun) when is_list(html) do
    Enum.map(html, &map(&1, fun))
  end
  def map({name, attrs, rest}, fun) do
    {new_name, new_attrs, new_rest} = fun.({name, attrs, rest})

    {new_name, new_attrs, Enum.map(new_rest, &map(&1, fun))}
  end

  def map(other, _fun), do: other

end
