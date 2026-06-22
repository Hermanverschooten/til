defmodule TilWeb.SitemapXML do
  @moduledoc """
  Renders the sitemap. The `<?xml?>` prolog makes these templates invalid
  HEEx, so they are compiled from plain EEx instead.
  """
  require EEx

  EEx.function_from_file(
    :def,
    :sitemap,
    Path.join(__DIR__, "sitemap_xml/sitemap.xml.eex"),
    [:assigns]
  )
end
