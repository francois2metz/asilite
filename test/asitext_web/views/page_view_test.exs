defmodule AsitextWeb.PageViewTest do
  use AsitextWeb.ConnCase, async: true

  test "title_cleanup with nil" do
    assert AsitextWeb.PageView.title_cleanup(nil) == nil
  end

  test "title_cleanup replace &nbps;" do
    assert AsitextWeb.PageView.title_cleanup("&nbsp;PLOP&nbsp;") == " PLOP "
  end
end
