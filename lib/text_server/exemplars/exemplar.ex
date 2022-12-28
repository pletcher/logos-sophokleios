defmodule TextServer.Exemplars.Exemplar do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exemplars" do
    field :filemd5hash, :string
    field :filename, :string
    field :parsed_at, :naive_datetime
    field :source, :string
    field :source_link, :string

    belongs_to :version, TextServer.Versions.Version

    has_many :text_nodes, TextServer.TextNodes.TextNode

    embeds_one :tei_header, TextServer.Exemplars.TeiHeader

    timestamps()
  end

  @doc false
  def changeset(exemplar, attrs) do
    exemplar
    |> cast(attrs, [
      :filemd5hash,
      :filename,
      :parsed_at,
      :source,
      :source_link,
      :version_id
    ])
    |> cast_embed(:tei_header)
    |> validate_required([:filemd5hash, :filename])
    |> assoc_constraint(:version)
  end
end
