defmodule TilWeb.PageController do
  use TilWeb, :controller
  alias Til.ArticleServer

  def index(conn, _params) do
    articles = ArticleServer.articles(4)
    render(conn, "index.html", articles: articles)
  end

  def all(conn, _params) do
    articles =
      ArticleServer.articles(:all)
      |> Enum.group_by(&to_month/1)
      |> Enum.reverse()

    render(conn, "all.html", articles: articles)
  end

  def tags(conn, _params) do
    tags = ArticleServer.tags()

    articles = ArticleServer.articles(:all)

    result =
      for tag <- tags do
        list = Enum.filter(articles, &Enum.member?(&1.tags, tag))
        {tag, list}
      end

    render(conn, "tags.html", tagged: result)
  end

  def tagged(conn, %{"tag" => tag}) do
    with true <- Enum.member?(ArticleServer.tags(), tag) do
      articles = ArticleServer.articles(:all)

      list = Enum.filter(articles, &Enum.member?(&1.tags, tag))
      result = [{tag, list}]

      render(conn, "tags.html", tagged: result)
    else
      false ->
        conn
        |> put_status(:not_found)
        |> render(:"404")
    end
  end

  def asset(conn, %{"date" => date, "name" => name}) do
    with {:ok, filename} <- ArticleServer.asset(date, name) do
      conn
      |> send_download({:file, filename}, filename: Path.basename(filename))
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> render(:"404")
    end
  end

  defp to_month(%{date: date}) do
    case Date.from_iso8601(date) do
      {:ok, d} ->
        Timex.format!(d, "%Y%m", :strftime)

      _ ->
        "Before"
    end
  end

  def show(conn, %{"date" => date, "slug" => slug}) do
    with {:ok, %{prev: prev, current: article, next: next}} <- ArticleServer.find(date, slug) do
      render(conn, "article.html",
        article: article,
        prev: prev,
        next: next,
        page_title: article.title
      )
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> render(:"404")
    end
  end

  def reload(conn, _params) do
    ArticleServer.refresh()

    conn
    |> redirect(to: "/")
  end
end
