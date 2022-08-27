defmodule Til.ArticleServer do
  use GenServer
  alias Til.Article

  defstruct articles: [], tags: []

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

  def tags() do
    GenServer.call(__MODULE__, :tags)
  end

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def init(_) do
    {:ok, %__MODULE__{}, {:continue, :load_articles}}
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

  defp load_articles() do
    articles = Article.read()

    %__MODULE__{
      articles: articles,
      tags: Enum.flat_map(articles, & &1.tags) |> Enum.uniq() |> Enum.sort()
    }
  end
end
