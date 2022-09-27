defmodule Til.ArticleServer do
  use GenServer
  alias Til.Article

  defstruct articles: [], tags: [], assets: []

  def refresh() do
    GenServer.cast(__MODULE__, :refresh)
  end

  def articles() do
    GenServer.call(__MODULE__, :articles)
  end

  def articles(count) do
    GenServer.call(__MODULE__, {:articles, count})
  end

  def find(date, slug) do
    GenServer.call(__MODULE__, {:find, date, slug})
  end

  def asset(date, name) do
    GenServer.call(__MODULE__, {:asset, date, name})
  end

  def tags() do
    GenServer.call(__MODULE__, :tags)
  end

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  if Mix.env() == :dev do
    def init(_) do
      article_path = Application.get_env(:til, :article_path)
      {:ok, pid} = FileSystem.start_link(dirs: [article_path])
      FileSystem.subscribe(pid)

      {:ok, %__MODULE__{}, {:continue, :load_articles}}
    end

    def handle_info({:file_event, _watcher_pid, {_path, _events}}, _state) do
      IO.inspect("File changed, reloading articles")
      TilWeb.Endpoint.broadcast("phoenix:live_reload", "assets_change", %{asset_type: "heex"})
      {:noreply, load_articles()}
    end
  else
    def init(_) do
      {:ok, %__MODULE__{}, {:continue, :load_articles}}
    end
  end

  def handle_continue(:load_articles, _state) do
    {:noreply, load_articles()}
  end

  def handle_cast(:refresh, _state) do
    {:noreply, load_articles()}
  end

  def handle_call(:articles, _from, state) do
    {:reply, state.articles, state}
  end

  def handle_call({:articles, :all}, _from, state) do
    articles = Enum.filter(state.articles, & &1.live)

    {:reply, articles, state}
  end

  def handle_call({:articles, count}, _from, state) do
    articles =
      Enum.filter(state.articles, & &1.live)
      |> Enum.take(count)

    {:reply, articles, state}
  end

  def handle_call({:find, date, slug}, _from, state) do
    reply =
      case Enum.find(state.articles, fn
             %{date: ^date, slug: ^slug} -> true
             _ -> false
           end) do
        nil ->
          {:error, :not_found}

        current ->
          idx = Enum.find_index(state.articles, fn art -> art == current end)
          prev = if idx > 0, do: Enum.at(state.articles, idx - 1), else: nil
          next = Enum.at(state.articles, idx + 1)
          {:ok, %{prev: prev, current: current, next: next}}
      end

    {:reply, reply, state}
  end

  def handle_call(:tags, _from, state) do
    {:reply, state.tags, state}
  end

  def handle_call({:asset, date, name}, _from, state) do
    reply =
      case Enum.find(state.assets, fn
             %{date: ^date, name: ^name} -> true
             _ -> false
           end) do
        nil -> {:error, :not_found}
        asset -> {:ok, Til.Asset.file_path(asset)}
      end

    {:reply, reply, state}
  end

  defp load_articles() do
    articles = Article.read()

    %__MODULE__{
      articles: articles,
      tags: Enum.flat_map(articles, & &1.tags) |> Enum.uniq() |> Enum.sort(),
      assets: Til.Asset.build()
    }
  end
end
