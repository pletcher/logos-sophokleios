defmodule TextServer.Repo.Migrations.CreateVersions do
  use Ecto.Migration

  def change do
    create table(:versions) do
      add :description, :text
      add :title, :text, null: false
      add :urn, :text, null: false
      add :work_id, references(:works, on_delete: :nothing), null: false

      timestamps()
    end

    version_type_create_query = "CREATE TYPE version_type AS ENUM ('edition', 'translation')"
    version_type_drop_query = "DROP TYPE version_type"

    execute(version_type_create_query, version_type_drop_query)

    alter table(:versions) do
      add :version_type, :version_type, null: false
    end

    create unique_index(:versions, [:urn])
    create index(:versions, [:work_id])
  end
end
