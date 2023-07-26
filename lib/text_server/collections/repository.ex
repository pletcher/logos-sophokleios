defmodule TextServer.Collections.Repository do
  use Ecto.Schema
  import Ecto.Changeset

  schema "repositories" do
    field :url, :string

    belongs_to :collection, TextServer.Collections.Collection

    timestamps()
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [:collection_id, :url])
    |> validate_required([:url])
    |> assoc_constraint(:collection)
    |> unique_constraint(:url)
  end
end
