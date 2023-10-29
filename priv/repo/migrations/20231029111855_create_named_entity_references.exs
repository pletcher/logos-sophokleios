defmodule TextServer.Repo.Migrations.CreateNamedEntityReferences do
  use Ecto.Migration

  def change do
    create table(:named_entity_references) do
      add :urn, :jsonb, null: false
      add :start_offset, :integer, null: false
      add :end_offset, :integer, null: false
      add :named_entity_id, references(:named_entities, on_delete: :delete_all)

      timestamps()
    end

    create index(:named_entity_references, [:named_entity_id])
  end
end
