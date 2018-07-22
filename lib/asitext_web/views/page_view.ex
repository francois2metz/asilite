defmodule AsitextWeb.PageView do
  use AsitextWeb, :view

  def title_cleanup(nil) do
  end
  def title_cleanup(title) do
    String.replace(title, "&nbsp;", " ")
  end

  def download_link(link) do
    case String.starts_with?(link, "http") do
      true -> link
      false -> "https://v42.arretsurimages.net/fichiers/"<> link
    end
  end

  def render("show.json", %{article: article}) do
    article
  end
end
