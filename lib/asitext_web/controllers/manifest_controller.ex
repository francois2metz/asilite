defmodule AsitextWeb.ManifestController do
  use AsitextWeb, :controller

  def manifest(conn, _params) do
    manifest = %{
      name: "ASI Lite",
      description: "Affiche les contenu de arretsurimages.net d'une manière optimisée sur mobile.",
      short_name: "ASI Lite",
      start_url: "/",
      display: "standalone",
      icons: [
        %{
          src: "images/favicon.png",
          sizes: "64x64",
          type: "image/png"
        }
      ]
    }
    render conn, manifest: manifest
  end
end
