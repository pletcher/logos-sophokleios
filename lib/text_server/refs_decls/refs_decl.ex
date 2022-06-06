defmodule TextServer.RefsDecls.RefsDecl do
  use Ecto.Schema
  import Ecto.Changeset

  schema "refs_decls" do
    field :description, :string
    field :label, :string
    field :match_pattern, :string
    field :replacement_pattern, :string
    field :structure_index, :integer
    field :urn, :string

    belongs_to :exemplar, TextServer.Exemplars.Exemplar

    timestamps()
  end

  @doc false
  def changeset(refs_decl, attrs) do
    refs_decl
    |> cast(attrs, [
      :label,
      :description,
      :match_pattern,
      :replacement_pattern,
      :structure_index,
      :urn
    ])
    |> validate_required([
      :label,
      :description,
      :match_pattern,
      :replacement_pattern,
      :structure_index,
      :urn
    ])
    |> unique_constraint(:urn)
  end
end
