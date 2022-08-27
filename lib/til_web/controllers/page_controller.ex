defmodule TilWeb.PageController do
  use TilWeb, :controller
  alias Til.ArticleServer

  def index(conn, _params) do
    articles = ArticleServer.articles(4)
    render(conn, "index.html", articles: articles)
  end

  def show(conn, %{"date" => date, "slug" => slug}) do
    with {:ok, %{prev: prev, current: article, next: next}} <- ArticleServer.find(date, slug) do
      render(conn, "article.html", article: article, prev: prev, next: next)
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
