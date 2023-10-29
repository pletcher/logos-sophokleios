defmodule TextServer.NamedEntities.NamedEntity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "named_entities" do
    field :label, :string
    field :phrase, :string
    field :wikidata_id, :string
    field :wikidata_description, :string

    has_many :references, TextServer.NamedEntities.NamedEntityReference

    timestamps()
  end

  @doc false
  def changeset(named_entity, attrs) do
    named_entity
    |> cast(attrs, [:label, :phrase, :wikidata_id, :wikidata_description])
    |> validate_required([:label, :phrase, :wikidata_id, :wikidata_description])
    |> unique_constraint(:wikidata_id)
  end
end
