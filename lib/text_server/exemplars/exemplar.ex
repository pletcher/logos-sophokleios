defmodule TextServer.Exemplars.Exemplar do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exemplars" do
    field :description, :string
    field :filemd5hash, :string
    field :filename, :string
    field :label, :string
    field :source, :string
    field :source_link, :string
    field :structure, :string
    field :title, :string
    field :urn, :string

    belongs_to :language, TextServer.Languages.Language
    belongs_to :version, TextServer.Versions.Version

    embeds_one :tei_header, TextServer.Exemplars.TeiHeader

    timestamps()
  end

  @doc false
  def changeset(exemplar, attrs) do
    exemplar
    |> cast(attrs, [
      :description,
      :filemd5hash,
      :filename,
      :label,
      :language_id,
      :source,
      :source_link,
      :structure,
      :title,
      :urn,
      :version_id
    ])
    |> cast_embed(:tei_header)
    |> validate_required([:filemd5hash, :filename, :title, :urn])
    |> assoc_constraint(:language)
    |> assoc_constraint(:version)
    |> unique_constraint(:urn)
  end
end
