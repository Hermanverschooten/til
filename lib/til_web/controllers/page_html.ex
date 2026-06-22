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
    Earmark.as_html!(content,
      compact_output: false,
      smartypants: false,
      breaks: true,
      registered_processors: [{"img", &postprocess_image/1}]
    )
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

  def postprocess_image(node) do
    case Regex.run(~r{(.*)\|(.*)}, Earmark.AstTools.find_att_in_node(node, "src", ""),
           capture: :all_but_first
         ) do
      [url, extras] ->
        {tag, attrs, extra1, extra2} = node

        attrs = Enum.reject(attrs, fn {key, _val} -> key == "src" end)

        node = {tag, attrs, extra1, extra2}

        attrs =
          extras
          |> String.split(",")
          |> Enum.map(fn str -> String.split(str, "=", parts: 2) |> List.to_tuple() end)
          |> Enum.into(%{})
          |> Map.put("src", url)

        Earmark.AstTools.merge_atts_in_node(node, attrs)

      _ ->
        node
    end
  end
end
