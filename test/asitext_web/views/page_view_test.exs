defmodule AsitextWeb.PageViewTest do
  use AsitextWeb.ConnCase, async: true

  test "title_cleanup with nil" do
    assert AsitextWeb.PageView.title_cleanup(nil) == nil
  end

  test "title_cleanup replace &nbps;" do
    assert AsitextWeb.PageView.title_cleanup("&nbsp;PLOP&nbsp;") == " PLOP "
  end

  test "download_link prefix with the server url" do
    assert AsitextWeb.PageView.download_link("test.mkv") == "https://v42.arretsurimages.net/fichiers/test.mkv"
  end

  test "download_link don't prefix with the server url if a full url is present" do
    assert AsitextWeb.PageView.download_link("http://exemple.com/test.mkv") == "http://exemple.com/test.mkv"
  end
end
