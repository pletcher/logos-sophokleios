defmodule TextServer.Repo.Migrations.CreateRefsDeclarations do
  use Ecto.Migration

  def change do
    create table(:refs_declarations) do
      add :units, {:array, :string}
      add :delimiters, {:array, :string}
      add :match_patterns, {:array, :string}
      add :replacement_patterns, {:array, :string}
      add :raw, :text, null: false
      add :xml_version_id, references(:xml_versions, on_delete: :nothing)

      timestamps()
    end

    create index(:refs_declarations, [:xml_version_id])
  end
end
