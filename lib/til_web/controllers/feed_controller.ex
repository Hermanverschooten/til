defmodule TilWeb.FeedController do
  use TilWeb, :controller
  alias Til.ArticleServer

  def feeds(conn, _params) do
    articles =
      ArticleServer.articles(:all)
      |> Enum.map(fn %{date: date} = article -> Map.put(article, :published, published(date)) end)

    published = first_article_published(articles)

    conn
    |> put_resp_content_type("application/rss+xml")
    |> render("feeds.xml", articles: articles, published: published)
  end

  def css(conn, _params) do
    css =
      [
        File.read!(Application.app_dir(:til, "priv/static/assets/app.css")),
        TilWeb.LayoutView.stylesheet()
      ]
      |> Enum.join("\n")

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_download({:binary, css}, filename: "app.css")
  end

  defp first_article_published([%{published: pubDate} | _]), do: pubDate
  defp first_article_published(_), do: format(Date.utc_today())

  defp published(pubDate) do
    case Date.from_iso8601(pubDate) do
      {:ok, date} -> format(date)
      {:error, _} -> format(Date.utc_today())
    end
  end

  defp format(date) do
    date
    |> Timex.to_datetime()
    |> Timex.lformat!("{RFC1123}", "Europe/Brussels")
  end
end
