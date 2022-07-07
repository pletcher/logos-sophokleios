defmodule TextServer.Repo.Migrations.CreateIngestionItems do
  use Ecto.Migration

  def change do
    create table(:ingestion_items) do
      add :path, :string, null: false
      add :collection_id, references(:collections, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:ingestion_items, [:path])
  end
end
