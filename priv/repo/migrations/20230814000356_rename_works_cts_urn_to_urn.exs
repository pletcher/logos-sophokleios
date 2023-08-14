defmodule TextServer.Repo.Migrations.RenameWorksCtsUrnToUrn do
  use Ecto.Migration

  def change do
    alter table(:works) do
      remove :urn
    end

    flush()

    rename table(:works), :cts_urn, to: :urn

    flush()

    alter table(:works) do
      modify :urn, :map, null: false, from: {:map, null: true}
    end
  end
end
