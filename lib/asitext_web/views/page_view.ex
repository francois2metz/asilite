defmodule AsitextWeb.PageView do
  use AsitextWeb, :view

  def title_cleanup(nil) do
  end
  def title_cleanup(title) do
    String.replace(title, "&nbsp;", " ")
  end
end
