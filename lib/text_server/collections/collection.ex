defmodule TextServer.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :repository, :string
    field :title, :string
    field :urn, :string
    field :urn_fragment, :string

    has_many :repositories, TextServer.Collections.Repository
    has_many :text_groups, TextServer.TextGroups.TextGroup

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:repository, :title, :urn, :urn_fragment])
    |> validate_required([:repository, :title, :urn, :urn_fragment])
    |> unique_constraint(:repository)
  end
end
