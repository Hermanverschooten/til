defmodule TilWeb.FeedController do
  use TilWeb, :controller
  alias Til.ArticleServer

  def feeds(conn, _params) do
    articles =
      ArticleServer.articles(:all)
      |> Enum.map(fn %{date: date} = article -> Map.put(article, :published, published(date)) end)

    published = first_article_published(articles)

    conn
    |> render("feeds.xml", articles: articles, published: published)
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
    |> Timex.lformat!("{RFC822}", "Europe/Brussels")
  end
end
