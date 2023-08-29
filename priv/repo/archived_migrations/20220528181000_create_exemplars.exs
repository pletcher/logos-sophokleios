defmodule TextServer.Repo.Migrations.CreateExemplars do
  use Ecto.Migration

  def change do
    create table(:exemplars) do
      add :description, :text
      add :filemd5hash, :string, null: false
      add :filename, :text, null: false
      add :label, :string
      add :language_id, references(:languages, on_delete: :nothing), null: false
      add :source, :text
      add :source_link, :text
      add :structure, :string
      add :title, :text, null: false
      add :urn, :text, null: false

      add :version_id, references(:versions, on_delete: :restrict), null: false

      timestamps()
    end

    create unique_index(:exemplars, [:filemd5hash])
    create index(:exemplars, [:language_id])
    create unique_index(:exemplars, [:urn])

    create index(:exemplars, [:version_id])
  end
end
