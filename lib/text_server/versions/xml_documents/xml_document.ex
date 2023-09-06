defmodule TextServer.Versions.XmlDocuments.XmlDocument do
  use Ecto.Schema
  import Ecto.Changeset

  schema "xml_documents" do
    field :document, :string

    belongs_to :version, TextServer.Versions.Version

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:document, :version_id])
    |> cast_assoc(:version)
    |> validate_required([:document])
  end
end
