defmodule TilWeb.PageController do
  use TilWeb, :controller
  alias Til.Articles

  def index(conn, _params) do
    articles = Articles.list(4)
    render(conn, "index.html", articles: articles)
  end
end
