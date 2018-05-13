defmodule Asi.HTML do
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

  defp rewrite_tag({"asi-html", attributes, rest}, _) do
    {"div", attributes, rest}
  end

  defp rewrite_tag({"asi-citation", attributes, rest}, _) do
    {attributes, class} = without_key(attributes, "class")
    {"div", [{"class", "citation "<> class} | attributes], rest}
  end

  defp rewrite_tag({"read-more", _attributes, _rest}, _) do
    {"div", [], []}
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

  defp rewrite_tag({"style", _, _}, _) do
    {"style", [], []}
  end

  defp rewrite_tag(other, _) do
    other
  end

  defp rewrite_href(href) do
    href
    |> String.replace(~r/^\/([^\/]+)\/[0-9-]+\/(.+)/, "/\\1/\\2")
    |> String.replace(~r/^\/([^\/]+)\/(.+)-id[0-9]+/, "/\\1/\\2")
    |> String.replace(~r/https:\/\/(beta|www).arretsurimages.net\/([^\/]+)\/[0-9-]+\/(.+)/, "/\\2/\\3")
    |> String.replace(~r/https:\/\/(beta|www).arretsurimages.net\/([^\/]+)\/([^\/]+)/, "/\\2/\\3")
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
