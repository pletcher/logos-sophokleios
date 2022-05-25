defmodule TextServer.Texts.TextGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_groups" do
    field :slug, :string
    field :title, :string
    field :urn, :string

    belongs_to :collection, TextServer.Texts.Collection
    has_many :works, TextServer.Texts.Work

    timestamps()
  end

  @doc false
  def changeset(text_group, attrs) do
    text_group
    |> cast(attrs, [:slug, :title, :urn])
    |> validate_required([:collection_id, :title, :urn])
    |> unique_constraint([:collection_id, :urn])
  end
end
