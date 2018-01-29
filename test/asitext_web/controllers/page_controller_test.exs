defmodule AsitextWeb.PageControllerTest do
  use AsitextWeb.ConnCase

  test "rewrite links new" do
    html = ~s(<div><a href="https://beta.arretsurimages.net/articles/france-bleu">test</a></div>)
    assert AsitextWeb.PageController.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "rewrite old links" do
    html = ~s(<div><a href="https://beta.arretsurimages.net/articles/2017-12-12/france-bleu">test</a></div>)
    assert AsitextWeb.PageController.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "rewrite absolute links" do
    html = ~s(<div><a href="/articles/2017-12-12/france-bleu">test</a></div>)
    assert AsitextWeb.PageController.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "remove target blank from links" do
    html = ~s(<div><a href="/articles/2017-12-12/france-bleu" target="_blank">test</a></div>)
    assert AsitextWeb.PageController.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "dont rewrite no links" do
    html = ~s(<div><a href="http://lemonde.fr/articles/2017-12-12/france-bleu">test</a></div>)
    assert AsitextWeb.PageController.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="http://lemonde.fr/articles/2017-12-12/france-bleu">test</a></div>)
  end

  test "rewrite asi-image to div" do
    html = ~s(<div><asi-image class="no-remove" slug="test">Content</asi-image></div>)
    assert AsitextWeb.PageController.rewrite_html(html, fn -> :ok end) == ~s(<div><div class="image no-remove" slug="test"><img src="https://api.arretsurimages.net/api/public/media/test/action/show?format=public" alt=""/></div></div>)
  end

  test "support rewrite asi-image to div without class" do
    html = ~s(<div><asi-image slug="test">Content</asi-image></div>)
    assert AsitextWeb.PageController.rewrite_html(html, fn -> :ok end) == ~s(<div><div class="image " slug="test"><img src="https://api.arretsurimages.net/api/public/media/test/action/show?format=public" alt=""/></div></div>)
  end

  test "rewrite asi-encadre to div" do
    html = ~s(<div><asi-encadre class="no-remove">Content</asi-encadre></div>)
    assert AsitextWeb.PageController.rewrite_html(html, fn -> :ok end) == ~s(<div><div class="encadre no-remove">Content</div></div>)
  end

  test "don't rewrite other div" do
    html = ~s(<div><div class="no-remove">Content</div></div>)
    assert AsitextWeb.PageController.rewrite_html(html, fn -> :ok end) == ~s(<div><div class="no-remove">Content</div></div>)
  end

  test "rewrite asi-video to use iframe" do
    html = ~s(<div><asi-video class="no-remove" slug="my-video">Content</asi-video></div>)
    assert AsitextWeb.PageController.rewrite_html(html, fn _ -> %{body: %{"metas" => %{"embed_url" => "https://exemple.net/my-video"}}} end) == ~s(<div><div class="embed-responsive embed-responsive-16by9"><iframe src="https://exemple.net/my-video" allowfullscreen="true" class="no-remove" slug="my-video"></iframe></div></div>)
  end
end
