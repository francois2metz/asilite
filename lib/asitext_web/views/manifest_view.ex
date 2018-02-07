defmodule AsitextWeb.ManifestView do
  use AsitextWeb, :view

  def render("manifest.json", %{manifest: manifest}) do
    manifest
  end
end
