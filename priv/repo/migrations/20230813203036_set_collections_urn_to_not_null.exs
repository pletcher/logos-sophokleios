defmodule TextServer.Repo.Migrations.SetCollectionsUrnToNotNull do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      modify :urn, :map, null: false, from: {:map, null: true}
    end
  end
end
