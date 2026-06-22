defmodule TilWeb.PageHTMLTest do
  use ExUnit.Case, async: true

  alias TilWeb.PageHTML

  describe "date/1" do
    test "formats an ISO date string" do
      assert PageHTML.date("2022-08-27") == "Aug 27,2022"
    end

    test "formats a Date" do
      assert PageHTML.date(~D[2022-08-27]) == "Aug 27,2022"
    end

    test "reports an invalid date string" do
      assert PageHTML.date("nope") == "Invalid date 'nope'"
    end
  end

  describe "month/1" do
    test "formats a YYYYMM string" do
      assert PageHTML.month("202208") == "Aug, 2022"
    end

    test "reports an invalid month string" do
      assert PageHTML.month("bogus") == "Invalid date"
    end
  end

  describe "markdown/1" do
    test "renders headings with utility classes" do
      assert PageHTML.markdown("# Hi") =~ ~s(<h1 class="text-3xl font-medium my-2">Hi</h1>)
    end

    test "syntax-highlights elixir code blocks via makeup" do
      html = PageHTML.markdown("```elixir\nx = 1\n```")
      assert html =~ ~s(<code class="makeup elixir">)
      assert html =~ ~s(<span class=)
    end

    test "leaves unknown code languages untouched" do
      html = PageHTML.markdown("```text\nplain\n```")
      assert html =~ ~s(<pre><code class="language-text">plain)
      refute html =~ "makeup"
    end

    test "renders GFM tables" do
      html = PageHTML.markdown("| A | B |\n|---|---|\n| 1 | 2 |")
      assert html =~ "<table>"
      assert html =~ "<th>A</th>"
    end

    test "passes through raw HTML" do
      assert PageHTML.markdown(~s(<div class="raw">kept</div>)) =~
               ~s(<div class="raw">kept</div>)
    end

    test "turns soft line breaks into <br>" do
      assert PageHTML.markdown("one\ntwo") =~ "<br />"
    end

    test "promotes pipe image attributes to tag attributes" do
      html = PageHTML.markdown("![alt](https://x/a.png|width=300,class=rounded)")
      assert html =~ ~s(src="https://x/a.png")
      assert html =~ ~s(width="300")
      assert html =~ ~s(class="rounded")
      refute html =~ "%7C"
    end
  end
end
