defmodule TilWeb.SitemapController do
  use TilWeb, :controller
  alias Til.ArticleServer

  def sitemap(conn, _params) do
    articles =
      ArticleServer.articles(:all)
      |> Enum.map(fn article ->
        %{
          loc: Routes.page_url(conn, :show, article.date, article.slug),
          lastmod: article.date,
          changefreq: "monthly"
        }
      end)

    urlset = [
      %{loc: Routes.page_url(conn, :index), lastmod: Date.utc_today(), changefreq: "always"}
      | articles
    ]

    conn
    |> render("sitemap.xml", urlset: urlset)
  end
end
