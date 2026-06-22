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
end
