defmodule TextServer.Repo.Migrations.CreateExemplars do
  use Ecto.Migration

  def change do
    create table(:exemplars) do
      add :description, :string
      add :slug, :string
      add :title, :string
      add :urn, :string
      add :work_id, references(:works, on_delete: :nothing)

      timestamps()
    end

    create index(:exemplars, [:work_id])
  end
end
