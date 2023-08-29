defmodule TextServer.Repo.Migrations.RemoveUrnFragments do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      remove :urn_fragment
    end

    alter table(:text_groups) do
      remove :urn_fragment
    end
  end
end
