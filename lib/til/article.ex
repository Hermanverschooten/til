defmodule Til.Article do
  defstruct slug: "",
            title: "",
            tldr: "",
            content: "",
            live: false,
            date: nil,
            tags: [],
            author: "",
            category: ""

  def read() do
    for file <- Path.wildcard("#{path()}/**/*.md"),
        [date, name] = Path.split(file) |> Enum.take(-2) do
      with {:ok, data} <- read_file(date, name) do
        parse_file(date, name, data)
      end
    end
    |> Enum.sort(fn a, b -> a.date >= b.date && a.title <= b.title end)
  end

  defp read_file(date, name) do
    File.read(path([date, name]))
  end

  def parse_file(date, name, data) do
    %__MODULE__{
      slug: Path.rootname(name),
      date: date,
      title: title(data),
      tldr: tldr(data),
      author: author(data),
      content: content(data),
      live: visible?(data),
      tags: tags(data),
      category: category(data) || "technology"
    }
  end

  defp visible?(data), do: Regex.match?(~r/^visible\n/i, data)

  defp title(data) do
    Regex.run(~r/-- TITLE --\n(.*)\n--/, data, capture: :all_but_first)
    |> to_str()
  end

  defp tldr(data) do
    Regex.run(~r/-- TLDR --\n(.*)\n--/s, data, capture: :all_but_first)
    |> to_str()
  end

  defp author(data) do
    Regex.run(~r/-- AUTHOR --\n(.*)\n--/, data, capture: :all_but_first)
    |> parse_author()
  end

  defp content(data) do
    Regex.run(~r/-- CONTENT --\n(.*)/s, data, capture: :all_but_first)
    |> to_str()
  end

  defp tags(data) do
    Regex.run(~r/-- TAGS --\n([^--]*+)/, data, capture: :all_but_first)
    |> case do
      nil ->
        []

      [tags] ->
        tags
        |> String.split(~r/\n+/, trim: true)
    end
  end

  defp to_str(nil), do: ""
  defp to_str(str) when is_binary(str), do: str
  defp to_str(list) when is_list(list), do: Enum.join(list)

  defp category(data) do
    Regex.run(~r/-- CATEGORY --\n(.*)\n--/, data, capture: :all_but_first)
  end

  defp path(list) when is_list(list) do
    Enum.reduce(list, path(), fn folder, path ->
      Path.join(path, folder)
    end)
  end

  defp path(), do: Application.get_env(:til, :article_path)

  defp parse_author(nil), do: parse_author([""])

  defp parse_author([author]) do
    cond do
      Regex.match?(~r/^\S+@\S+ \(.*\)$/, author) ->
        author

      Regex.match?(~r/.* <.*>$/, author) ->
        [name, email] = Regex.run(~r/(.*) <(.*)>$/, author, capture: :all_but_first)
        "#{email} (#{name})"

      true ->
        "Herman@verschooten.net (Herman verschooten)"
    end
  end
end
