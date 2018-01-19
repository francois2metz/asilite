defmodule AsitextWeb.LayoutView do
  use AsitextWeb, :view

  def nav_links do
    [
      {"articles", "Articles"},
      {"emissions", "Émissions"},
      {"chroniques", "Chroniques"},
    ]
  end
end
