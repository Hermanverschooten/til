defmodule TilWeb.FeedView do
  use TilWeb, :view

  defdelegate markdown(content), to: TilWeb.PageView
end
