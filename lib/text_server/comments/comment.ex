defmodule TextServer.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :attributes, :map
    field :content, :string
    field :urn, TextServer.Ecto.Types.CTS_URN

    belongs_to :text_node, TextServer.TextNodes.TextNode
    belongs_to :version, TextServer.Versions.Version

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:attributes, :content, :text_node_id, :version_id, :urn])
    |> cast_assoc(:text_node)
    |> cast_assoc(:version)
    |> validate_required([:content, :urn])
  end
end
