defmodule TilWeb.SitemapControllerTest do
  use TilWeb.ConnCase, async: true

  test "GET /sitemap.xml renders a urlset", %{conn: conn} do
    conn = get(conn, ~p"/sitemap.xml")

    assert response_content_type(conn, :xml)
    body = response(conn, 200)
    assert body =~ "<urlset"
    assert body =~ "<loc>"
  end
end
