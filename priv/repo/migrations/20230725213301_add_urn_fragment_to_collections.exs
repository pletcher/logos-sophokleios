defmodule TextServer.Repo.Migrations.AddUrnFragmentToCollections do
  use Ecto.Migration

  def up do
    alter table(:collections) do
      add :urn_fragment, :string, null: true
    end

    flush()

    TextServer.Collections.list_collections()
    |> Enum.each(fn collection ->
      urn = collection.urn
      [_prefix, _protocol, namespace] = String.split(urn, ":")
      {:ok, _c} = TextServer.Collections.update_collection(collection, %{urn_fragment: namespace})
    end)

    # We're going to remove these, so don't run this part of the migration in production
    # alter table(:collections) do
    #   modify :urn_fragment, :string, null: false, from: {:string, null: true}
    # end
  end

  def down do
    alter table(:collections) do
      remove :urn_fragment
    end
  end
end
