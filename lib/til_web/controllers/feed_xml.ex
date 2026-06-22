defmodule TilWeb.FeedXML do
  @moduledoc """
  Renders the RSS feed. The `<?xml?>` prolog makes these templates invalid
  HEEx, so they are compiled from plain EEx instead.
  """
  use Phoenix.VerifiedRoutes,
    endpoint: TilWeb.Endpoint,
    router: TilWeb.Router,
    statics: TilWeb.static_paths()

  require EEx

  defdelegate markdown(content), to: TilWeb.PageHTML

  EEx.function_from_file(:def, :feeds, Path.join(__DIR__, "feed_xml/feeds.xml.eex"), [:assigns])
end
