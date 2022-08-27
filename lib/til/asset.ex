defmodule Til.Asset do
  defstruct date: nil, name: ""

  def build() do
    files =
      Path.wildcard("#{path()}/**/*.*")
      |> Enum.reject(fn file -> Path.extname(file) == ".md" end)

    for file <- files, [_, date, name] = Path.split(file) do
      %__MODULE__{date: date, name: name}
    end
  end

  def file_path(%__MODULE__{date: date, name: name}), do: file_path(date, name)

  def file_path(date, name) do
    path([date, name])
  end

  defp path(list) when is_list(list) do
    Enum.reduce(list, path(), fn folder, path ->
      Path.join(path, folder)
    end)
  end

  defp path(), do: Application.get_env(:til, :article_path)
end
