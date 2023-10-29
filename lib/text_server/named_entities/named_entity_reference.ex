defmodule TextServer.NamedEntities.NamedEntityReference do
  use Ecto.Schema
  import Ecto.Changeset

  schema "named_entity_references" do
    field :urn, TextServer.Ecto.Types.CTS_URN
    field :start_offset, :integer
    field :end_offset, :integer

    belongs_to :named_entity, TextServer.NamedEntities.NamedEntity

    timestamps()
  end

  @doc false
  def changeset(named_entity_reference, attrs) do
    named_entity_reference
    |> cast(attrs, [:urn, :start_offset, :end_offset])
    |> validate_required([:urn, :start_offset, :end_offset])
    |> assoc_constraint(:named_entity)
  end
end
