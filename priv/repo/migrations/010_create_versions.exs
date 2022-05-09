defmodule TextServer.Repo.Migrations.CreateVersions do
  use Ecto.Migration

  def change do
    create table(:versions) do
      add :description, :string
      add :slug, :string
      add :title, :string
      add :urn, :string
      add :work_id, references(:works, on_delete: :nothing)

      timestamps()
    end

    create index(:versions, [:work_id])
  end
end
