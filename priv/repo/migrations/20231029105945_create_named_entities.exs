defmodule TextServer.Repo.Migrations.CreateNamedEntities do
  use Ecto.Migration

  def change do
    create table(:named_entities) do
      add :label, :string, null: false
      add :phrase, :string, null: false
      add :wikidata_id, :string, null: false
      add :wikidata_description, :string, null: false

      timestamps()
    end

    create unique_index(:named_entities, [:wikidata_id])
  end
end
