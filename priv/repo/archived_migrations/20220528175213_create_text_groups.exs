defmodule TextServer.Repo.Migrations.CreateTextGroups do
  use Ecto.Migration

  def change do
    create table(:text_groups) do
      add :title, :string, null: false
      add :urn, :text, null: false
      add :collection_id, references(:collections, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:text_groups, [:collection_id, :urn])
    create index(:text_groups, [:collection_id])
  end
end
