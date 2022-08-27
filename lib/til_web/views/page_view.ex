defmodule TilWeb.PageView do
  use TilWeb, :view

  def date(date) do
    Timex.format(date, "%b %d,%Y", :strftime)
  end
end
