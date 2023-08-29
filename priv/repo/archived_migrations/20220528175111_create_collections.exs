defmodule TextServer.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :repository, :string, null: false
      add :title, :string, null: false
      add :urn, :string, null: false

      timestamps()
    end

    create unique_index(:collections, [:repository])
  end
end
