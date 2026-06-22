defmodule TilWeb.PageHTML do
  use TilWeb, :html

  embed_templates "page_html/*"

  def date(str) when is_binary(str) do
    case Date.from_iso8601(str) do
      {:ok, date} -> date(date)
      {:error, _} -> "Invalid date '#{str}'"
    end
  end

  def date(date) do
    Calendar.strftime(date, "%b %d,%Y")
  end

  def month(str) do
    with <<year::binary-size(4), month::binary-size(2)>> <- str,
         {year, ""} <- Integer.parse(year),
         {month, ""} <- Integer.parse(month),
         {:ok, date} <- Date.new(year, month, 1) do
      Calendar.strftime(date, "%b, %Y")
    else
      _ -> "Invalid date"
    end
  end

  def article_path(%{date: date, slug: slug}), do: ~p"/til/#{date}/#{slug}"

  def markdown(content) do
    content
    |> MDEx.to_html!(
      extension: [table: true, autolink: true, strikethrough: true, tasklist: true],
      parse: [smart: false],
      render: [hardbreaks: true, unsafe: true]
    )
    |> postprocess_images()
    |> Til.Highlighter.highlight()
    |> highlight_html()
  end

  @replacements %{
    "<h1>" => ~s|<h1 class="text-3xl font-medium my-2">|,
    "<h2>" => ~s|<h2 class="text-2xl font-medium my-2">|,
    "<h3>" => ~s|<h3 class="text-xl font-medium italic my-2">|,
    "<p>" => ~s|<p class="my-1">|
  }

  defp highlight_html(content) do
    Enum.reduce(@replacements, content, fn {r, c}, content ->
      Regex.replace(~r/#{r}/, content, c)
    end)
  end

  # Supports the custom `![alt](url|key=value,key=value)` image syntax: MDEx
  # url-encodes the pipe to `%7C`, so split the rendered <img> src on it and
  # promote the comma-separated key=value pairs to attributes.
  defp postprocess_images(html) do
    Regex.replace(~r/<img src="([^"]*?)%7[Cc]([^"]*?)"([^>]*?)\s*\/?>/, html, fn _full,
                                                                                 url,
                                                                                 extras,
                                                                                 rest ->
      attrs =
        extras
        |> String.split(",")
        |> Enum.map_join(" ", fn pair ->
          case String.split(pair, "=", parts: 2) do
            [key, value] -> ~s(#{key}="#{value}")
            [key] -> key
          end
        end)

      ~s(<img src="#{url}" #{attrs}#{rest} />)
    end)
  end
end
