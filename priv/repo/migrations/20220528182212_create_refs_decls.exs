defmodule TextServer.Repo.Migrations.CreateRefsDecls do
  use Ecto.Migration

  def change do
    create table(:refs_decls) do
      add :description, :text
      add :label, :string
      add :match_pattern, :string
      add :replacement_pattern, :string
      add :structure_index, :integer
      add :urn, :text, null: false
      add :exemplar_id, references(:exemplars, on_delete: :restrict), null: false

      timestamps()
    end

    create unique_index(:refs_decls, [:urn, :exemplar_id])

    create index(:refs_decls, [:exemplar_id])
  end
end
