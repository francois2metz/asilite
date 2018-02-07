defmodule AsitextWeb.ManifestController do
  use AsitextWeb, :controller

  def manifest(conn, _params) do
    manifest = %{
      name: "ASI Lite",
      description: "Affiche les contenu de arretsurimages.net d'une manière optimisée sur mobile.",
    }
    render conn, manifest: manifest
  end
end
