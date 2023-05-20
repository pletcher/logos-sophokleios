defmodule TextServer.XML.RefsDeclaration do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  See https://tei-c.org/release/doc/tei-p5-doc/en/html/SA.html#SACR

  Unfortunately, TEI provides a lot of options for handling
  references. Ideally, we will insist on a small subset of what
  they allow.
  """

  schema "refs_declarations" do
    field :delimiters, {:array, :string}
    field :match_patterns, {:array, :string}
    field :raw, :string
    field :replacement_patterns, {:array, :string}
    field :units, {:array, :string}

    belongs_to :xml_version, TextServer.XML.Version, foreign_key: :xml_version_id

    timestamps()
  end

  @doc false
  def changeset(refs_declaration, attrs) do
    refs_declaration
    |> cast(attrs, [
      :units,
      :delimiters,
      :match_patterns,
      :replacement_patterns,
      :raw,
      :xml_version_id
    ])
    |> cast_assoc(:xml_version)
    |> validate_required([:units, :match_patterns, :replacement_patterns, :raw])
  end
end
