defmodule AsitextWeb.PageController do
  use AsitextWeb, :controller

  def index(conn, _params) do
    results  = Asi.get("search?q=").body
    title = "Accueil"
    render conn, "index.html", title: title, results: results
  end

  def show(conn, %{"type" => type, "slug" => slug}) do
    article = Asi.get("contents/" <> type <> "/" <> slug).body
    title   = article["title"]
    render conn, "show.html", article: article, title: title
  end
end
