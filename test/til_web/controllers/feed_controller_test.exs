defmodule TilWeb.FeedControllerTest do
  use TilWeb.ConnCase, async: true

  test "GET /feed renders an RSS document", %{conn: conn} do
    conn = get(conn, ~p"/feed")

    assert response_content_type(conn, :xml) =~ "rss"
    body = response(conn, 200)
    assert body =~ ~s(<?xml version="1.0" encoding="utf-8"?>)
    assert body =~ "<rss version=\"2.0\""
    assert body =~ "TIL - Herman verschooten"
  end

  test "GET /feed.css returns the stylesheet", %{conn: conn} do
    conn = get(conn, ~p"/feed.css")
    assert response(conn, 200) =~ "makeup"
  end
end
