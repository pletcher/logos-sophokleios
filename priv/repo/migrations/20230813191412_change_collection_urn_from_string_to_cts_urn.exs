defmodule TextServer.Repo.Migrations.ChangeCollectionUrnFromStringToCtsUrn do
  use Ecto.Migration

  alias TextServer.Collections
  alias TextServer.Collections.Collection

  def change do
    alter table(:collections) do
      add :cts_urn, :map
    end

    flush()

    Collections.list_collections()
    |> Enum.each(fn collection ->
      Collections.update_collection(collection, %{cts_urn: collection.urn})
    end)
  end
end
