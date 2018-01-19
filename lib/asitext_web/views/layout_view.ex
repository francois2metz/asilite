defmodule AsitextWeb.LayoutView do
  use AsitextWeb, :view

  def nav_links do
    [
      {"articles", "Articles"},
      {"emissions", "Émisions"},
      {"chroniques", "Chroniques"},
    ]
  end
end
