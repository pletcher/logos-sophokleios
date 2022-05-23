defmodule TextServer.Repo.Migrations.CreateTextGroups do
  use Ecto.Migration

  def change do
    create table(:text_groups) do
      add :slug, :string, unique: true
      add :title, :string, null: false
      add :urn, :string, null: false
      add :collection_id, references(:collections, on_delete: :delete_all)

      timestamps()
    end

    create index(:text_groups, [:collection_id])
    create unique_index(:text_groups, [:urn, :collection_id])
  end
end
