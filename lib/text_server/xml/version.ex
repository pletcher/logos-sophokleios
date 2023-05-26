defmodule TextServer.Xml.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "xml_versions" do
    field :version_type, Ecto.Enum, values: [:commentary, :edition, :translation]
    field :urn, :string
    field :xml_document, :string

    belongs_to :work, TextServer.Works.Work

    has_one :refs_declaration, TextServer.Xml.RefsDeclaration, foreign_key: :xml_version_id

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:xml_document, :urn, :version_type, :work_id])
    |> cast_assoc(:work)
    |> validate_required([:xml_document, :urn, :version_type])
    |> unique_constraint(:urn)
  end
end
