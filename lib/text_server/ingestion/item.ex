defmodule TextServer.Ingestion.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ingestion_items" do
    field :path, :string

    belongs_to :collection, TextServer.Collections.Collection

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:path])
    |> validate_required([:path])
    |> unique_constraint(:path)
  end
end
