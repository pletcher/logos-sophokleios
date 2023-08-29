defmodule TextServer.Repo.Migrations.CreateXmlVersions do
  use Ecto.Migration

  def change do
    create table(:xml_versions) do
      add :xml_document, :xml, null: false
      add :urn, :string, null: false
      # See migration for original versions for this type
      add :version_type, :version_type, null: false
      add :work_id, references(:works, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:xml_versions, [:urn])
    create index(:xml_versions, [:work_id])
  end
end
