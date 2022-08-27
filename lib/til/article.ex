defmodule Til.Article do
  defstruct slug: "", title: "", tldr: "", content: "", live: false, date: nil, tags: []

  def list(_count) do
    []
  end

  def read() do
    for date <- File.ls!(path()), name <- File.ls!(path(date)) do
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
    [visible, title, tags, tldr, content] =
      String.split(data, ~r/\n-- (TITLE|TAGS|TLDR|CONTENT) --\n/, parts: 5)

    %__MODULE__{
      slug: Path.rootname(name),
      date: date,
      title: title,
      tldr: tldr,
      content: content,
      live: visible == "visible",
      tags: String.split(tags, ~r/\n+/)
    }
  end

  defp path(list) when is_list(list) do
    Enum.reduce(list, path(), fn folder, path ->
      Path.join(path, folder)
    end)
  end

  defp path(name) do
    Path.join(path(), name)
  end

  defp path(), do: Application.get_env(:til, :article_path)
end
