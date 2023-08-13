defmodule TextServer.Repo.Migrations.RenameCollectionCtsUrnToUrn do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      remove :urn
    end

    rename table(:collections), :cts_urn, to: :urn
  end
end
