defmodule TextServer.Texts.RefsDecl do
  use Ecto.Schema
  import Ecto.Changeset

  schema "refs_decls" do
    field :description, :string
    field :label, :string
    field :match_pattern, :string
    field :replacement_pattern, :string
    field :slug, :string
    field :structure_index, :integer
    field :urn, :string
    field :work_id, :id

    timestamps()
  end

  @doc false
  def changeset(refs_decl, attrs) do
    refs_decl
    |> cast(attrs, [:description, :label, :match_pattern, :replacement_pattern, :slug, :structure_index, :urn])
  end
end
