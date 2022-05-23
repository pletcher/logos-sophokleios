defmodule TextServer.Texts.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :repository, :string
    field :slug, :string
    field :title, :string
    field :urn, :string

    has_many :text_groups, TextServer.Texts.TextGroup

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:title, :slug, :urn, :repository])
    |> validate_required([:title, :urn, :repository])
    |> unique_constraint([:repository])
  end
end
