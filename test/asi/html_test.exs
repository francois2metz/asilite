defmodule Asi.HTMLTest do
  use ExUnit.Case, async: true

  test "rewrite links new" do
    html = ~s(<div><a href="https://beta.arretsurimages.net/articles/france-bleu">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "rewrite old links" do
    html = ~s(<div><a href="https://beta.arretsurimages.net/articles/2017-12-12/france-bleu">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "rewrite absolute links" do
    html = ~s(<div><a href="/articles/2017-12-12/france-bleu">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "rewrite absolute links with id" do
    html = ~s(<div><a href="/chroniques/2017-11-13/Des-defonces-des-cretins-et-des-causalites-id10318">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/chroniques/Des-defonces-des-cretins-et-des-causalites">test</a></div>)
  end

  test "rewrite old breves links" do
    html = ~s(<div><a href="/breves/2017-11-13/Des-defonces-des-cretins-et-des-causalites-id10318">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/Des-defonces-des-cretins-et-des-causalites">test</a></div>)
  end

  test "rewrite links with l'" do
    html = ~s(<div><a href="/chroniques/2017-11-13/canal-test-l-enquete-l-enquete">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/chroniques/canal-test-lenquete-lenquete">test</a></div>)
  end

  test "rewrite links with d'" do
    html = ~s(<div><a href="/chroniques/Reponse-d-un-boeuf-carotte-a-Cash-investigation">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/chroniques/Reponse-dun-boeuf-carotte-a-Cash-investigation">test</a></div>)
  end

  test "rewrite links with qu" do
    html = ~s(<div><a href="/chroniques/Lobby-du-tabac-le-lievre-de-Cash-investigation-n-est-il-qu-un-lapin-bizarre">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/chroniques/Lobby-du-tabac-le-lievre-de-Cash-investigation-nest-il-quun-lapin-bizarre">test</a></div>)
  end

  test "remove target blank from links" do
    html = ~s(<div><a href="/articles/2017-12-12/france-bleu" target="_blank">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "dont rewrite no links" do
    html = ~s(<div><a href="http://lemonde.fr/articles/2017-12-12/france-bleu">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="http://lemonde.fr/articles/2017-12-12/france-bleu">test</a></div>)
  end

  test "rewrite asi-image to div" do
    html = ~s(<div><asi-image class="no-remove" slug="test">Content</asi-image></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><div class="image no-remove"><img src="https://api.arretsurimages.net/api/public/media/test/action/show?format=public" alt=""/></div></div>)
  end

  test "support rewrite asi-image to div without class" do
    html = ~s(<div><asi-image slug="test">Content</asi-image></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><div class="image "><img src="https://api.arretsurimages.net/api/public/media/test/action/show?format=public" alt=""/></div></div>)
  end

  test "rewrite asi-encadre to div" do
    html = ~s(<div><asi-encadre class="no-remove">Content</asi-encadre></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><div class="encadre no-remove">Content</div></div>)
  end

  test "don't rewrite other div" do
    html = ~s(<div><div class="no-remove">Content</div></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><div class="no-remove">Content</div></div>)
  end

  test "rewrite asi-video to use iframe" do
    html = ~s(<div><asi-video class="no-remove" slug="my-video">Content</asi-video></div>)
    assert Asi.HTML.rewrite_html(html, fn _ -> %{body: %{"metas" => %{"embed_url" => "https://exemple.net/my-video"}}} end) == ~s(<div><div class="embed-responsive embed-responsive-16by9"><iframe src="https://exemple.net/my-video" allowfullscreen="true" class="no-remove"></iframe></div></div>)
  end

  test "rewrite asi-citation to a div" do
    html = ~s(<div><asi-citation class="no-remove">Content</asi-citation></div>)
    assert Asi.HTML.rewrite_html(html, fn _ -> :ok end) == ~s(<div><div class="citation no-remove">Content</div></div>)
  end

  test "rewrite asi-html to a div" do
    html = ~s(<div><asi-html>Content</asi-html></div>)
    assert Asi.HTML.rewrite_html(html, fn _ -> :ok end) == ~s(<div><div>Content</div></div>)
  end

  test "remove read-more" do
    html = ~s(<div><read-more type="content" slug="test">Content</read-more></div>)
    assert Asi.HTML.rewrite_html(html, fn _ -> :ok end) == ~s(<div><div></div></div>)
  end
end
