defmodule TilWeb.PageControllerTest do
  use TilWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "These things I recently learned"
  end

  test "GET /overview", %{conn: conn} do
    conn = get(conn, ~p"/overview")
    assert html_response(conn, 200) =~ "Today I Learned"
  end

  test "GET /tags", %{conn: conn} do
    conn = get(conn, ~p"/tags")
    assert html_response(conn, 200) =~ "Today I Learned"
  end

  test "GET an unknown article returns 404", %{conn: conn} do
    conn = get(conn, ~p"/til/2022-08-27/does-not-exist")
    assert html_response(conn, 404) =~ "Article not found"
  end
end
