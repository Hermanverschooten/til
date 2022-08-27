defmodule Til.Repo.Migrations.CreateArticlesTags do
  use Ecto.Migration

  def change do
    create table(:articles_tags, primary_key: false) do
      add :article_id, references(:articles), primary_key: true
      add :tag_id, references(:tags), primary_key: true
    end
  end
end
