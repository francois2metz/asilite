defmodule AsitextWeb.PageController do
  use AsitextWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
