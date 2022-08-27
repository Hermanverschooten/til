defmodule TilWeb.PageView do
  use TilWeb, :view

  def date(str) when is_binary(str) do
    case Date.from_iso8601(str) do
      {:ok, date} -> date(date)
      {:error, _} -> "Invalid date '#{str}'"
    end
  end

  def date(date) do
    Timex.format!(date, "%b %d,%Y", :strftime)
  end

  def url(%{date: date, slug: slug}), do: "/til/#{date}/#{slug}"

  def markdown(content) do
    Earmark.as_html!(content,
      compact_output: false,
      smartypants: false,
      breaks: true
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
end
