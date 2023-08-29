defmodule TextServer.Repo.Migrations.RenameTextGroupsCtsUrnToUrn do
  use Ecto.Migration

  def change do
    alter table(:text_groups) do
      remove :urn
    end

    flush()

    rename table(:text_groups), :cts_urn, to: :urn

    flush()

    alter table(:text_groups) do
      modify :urn, :map, null: false, from: {:map, null: true}
    end
  end
end
