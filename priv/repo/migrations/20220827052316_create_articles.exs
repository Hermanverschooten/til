defmodule Til.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :slug, :string
      add :title, :string
      add :tldr, :string
      add :content, :string
      add :live, :boolean, default: false
      add :date, :date
      timestamps()
    end

    create unique_index(:articles, [:slug])
    create index(:articles, ["date desc"])
  end
end
