defmodule TextServer.Repo.Migrations.CreateTextGroups do
  use Ecto.Migration

  def change do
    create table(:text_groups) do
      add :slug, :string, null: false, unique: true
      add :title, :string, null: false
      add :urn, :string, null: false, unique: true
      add :collection_id, references(:collections, on_delete: :nothing)

      timestamps()
    end

    create index(:text_groups, [:collection_id])
  end
end
