defmodule TilWeb.SitemapController do
  use TilWeb, :controller
  alias Til.ArticleServer

  def sitemap(conn, _params) do
    articles =
      ArticleServer.articles(:all)
      |> Enum.map(fn article ->
        %{
          loc: url(~p"/til/#{article.date}/#{article.slug}"),
          lastmod: article.date,
          changefreq: "monthly"
        }
      end)

    urlset = [
      %{loc: url(~p"/"), lastmod: Date.utc_today(), changefreq: "always"}
      | articles
    ]

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, TilWeb.SitemapXML.sitemap(%{urlset: urlset}))
  end
end
