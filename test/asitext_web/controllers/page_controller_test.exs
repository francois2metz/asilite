defmodule AsitextWeb.PageControllerTest do
  use AsitextWeb.ConnCase

  test "rewrite links new" do
    html = ~s(<div><a href="https://beta.arretsurimages.net/articles/france-bleu">test</a></div>)
    assert AsitextWeb.PageController.rewrite_html(html) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "rewrite old links" do
    html = ~s(<div><a href="https://beta.arretsurimages.net/articles/2017-12-12/france-bleu">test</a></div>)
    assert AsitextWeb.PageController.rewrite_html(html) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "rewrite absolute links" do
    html = ~s(<div><a href="/articles/2017-12-12/france-bleu">test</a></div>)
    assert AsitextWeb.PageController.rewrite_html(html) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "dont rewrite no links" do
    html = ~s(<div><a href="http://lemonde.fr/articles/2017-12-12/france-bleu">test</a></div>)
    assert AsitextWeb.PageController.rewrite_html(html) == ~s(<div><a href="http://lemonde.fr/articles/2017-12-12/france-bleu">test</a></div>)
  end

  test "rewrite asi-image to div" do
    html = ~s(<div><asi-image class="no-remove" slug="test">Content</asi-image></div>)
    assert AsitextWeb.PageController.rewrite_html(html) == ~s(<div><div class="image no-remove" slug="test">Content</div></div>)
  end
end
