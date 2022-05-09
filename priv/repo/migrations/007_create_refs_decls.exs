defmodule TextServer.Repo.Migrations.CreateRefsDecls do
  use Ecto.Migration

  def change do
    create table(:refs_decls) do
      add :description, :string
      add :label, :string
      add :match_pattern, :string
      add :replacement_pattern, :string
      add :slug, :string
      add :structure_index, :integer
      add :urn, :string
      add :work_id, references(:works, on_delete: :nothing)

      timestamps()
    end

    create index(:refs_decls, [:work_id])
  end
end
