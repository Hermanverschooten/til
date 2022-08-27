defmodule Til.ArticleTest do
  use ExUnit.Case

  alias Til.Article

  @article """
  visible
  -- TITLE --
  Transform from one Ecto.Schema to another with one command
  -- TAGS --
  elixir

  ecto
  -- TLDR --
  You can use `Schema.load/2` to transform from 1 `Ecto.Schema` to another.
  -- CONTENT --
  Recently I was struggling with a polymorphic table I made.
  The table contains documents of 4 different types, but they all adhere to almost the same structure.

  ...

  """

  setup_all do
    File.mkdir_p("tmp/articles/2022-08-27")
    File.write!("tmp/articles/2022-08-27/transform-ecto-schema.md", @article)

    on_exit(fn ->
      File.rm_rf!("tmp/articles/*")
    end)
  end

  test "reading the articles" do
    [article] = Article.read()

    assert article.live
    assert article.tags == ["elixir", "ecto"]
    assert article.date == "2022-08-27"
    assert article.slug == "transform-ecto-schema"
    assert article.title =~ "Transform"
    assert article.tldr =~ "You can use"
    assert article.content =~ "Recently I was struggling"
  end

  test "article order" do
    File.mkdir_p("tmp/articles/2022-08-24")

    File.write!(
      "tmp/articles/2022-08-24/some-til.md",
      String.replace(@article, ~r/Transform/, "Some")
    )

    File.write!(
      "tmp/articles/2022-08-27/more-info.md",
      String.replace(@article, ~r/Transform/, "More")
    )

    [art1, art2, art3] = Article.read()

    assert art1.date == "2022-08-27"
    assert art1.title =~ "More"
    assert art2.date == "2022-08-27"
    assert art2.title =~ "Transform"
    assert art3.date == "2022-08-24"
    assert art3.title =~ "Some"
  end
end
