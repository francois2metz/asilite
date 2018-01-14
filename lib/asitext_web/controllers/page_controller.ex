defmodule AsitextWeb.PageController do
  use AsitextWeb, :controller

  def index(conn, _params) do
    results  = Asi.get("search?q=").body
    title = "Accueil"
    render conn, "index.html", title: title, results: results
  end

  def article(conn, %{"slug" => slug}) do
    article = Asi.get("contents/articles/" <> slug).body
    title   = article["title"]
    render conn, "article.html", article: article, title: title
  end
end
