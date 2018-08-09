defmodule Asi.HTMLTest do
  use ExUnit.Case, async: true

  test "rewrite links from the beta" do
    html = ~s(<div><a href="https://beta.arretsurimages.net/articles/france-bleu">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "rewrite link from the new site" do
    html = ~s(<div><a href="https://www.arretsurimages.net/articles/france-bleu">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "rewrite old links" do
    html = ~s(<div><a href="https://beta.arretsurimages.net/articles/2017-12-12/france-bleu">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "do not rewrite absolute links" do
    html = ~s(<div><a href="/articles/france-bleu">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/articles/france-bleu">test</a></div>)
  end

  test "rewrite absolute links with id" do
    html = ~s(<div><a href="/chroniques/2017-11-13/Des-defonces-des-cretins-et-des-causalites-id10318">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/contenu.php?id=10318">test</a></div>)
  end

  test "rewrite old breves links" do
    html = ~s(<div><a href="/breves/2017-06-14/Crowdfunding-anti-refugies-PayPal-gele-la-collecte-des-identitaires-id20689">test</a></div>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<div><a href="/vite.php?id=20689">test</a></div>)
  end

  test "remove target blank from links" do
    html = ~s(<div><a href="/articles/france-bleu" target="_blank">test</a></div>)
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

  test "rewrite asi-video to use iframe for dailymotion videos" do
    body = %{"oembed" => %{"author_name" => "Arrêt sur Images", "author_url" => "https://www.dailymotion.com/asi", "description" => "", "height" => 269, "html" => "<iframe frameborder=\"0\" width=\"480\" height=\"269\" src=\"https://www.dailymotion.com/embed/video/plopplop\" allowfullscreen allow=\"autoplay\"></iframe>", "newId" => "dfdsfdsfsf", "provider_name" => "Dailymotion", "provider_url" => "https://www.dailymotion.com", "thumbnail_height" => 240, "thumbnail_url" => "https://s1-ssl.dmcdn.net/oy9zQ/x240-X7e.jpg", "thumbnail_width" => 427, "title" => "aliinterviewparisien", "type" => "video", "version" => "1.0", "width" => 480}}
    html = ~s(<div><asi-video class="no-remove" slug="my-video">Content</asi-video></div>)
    assert Asi.HTML.rewrite_html(html, fn _ -> %{body: body} end) == ~s(<div><div class="embed-responsive embed-responsive-16by9"><iframe src="https://www.dailymotion.com/embed/video/plopplop" allowfullscreen="true" class="no-remove"></iframe></div></div>)
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

  test "remove style tag (workaround floki bug)" do
    html = ~s(<style><!-- /* Font Definitions */ --></style>)
    assert Asi.HTML.rewrite_html(html, fn -> :ok end) == ~s(<style></style>)
  end
end
