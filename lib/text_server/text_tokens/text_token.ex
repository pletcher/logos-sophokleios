defmodule TextServer.TextTokens.TextToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_tokens" do
    field :content, :string
    field :offset, :integer
    field :word, :string

    belongs_to :text_node, TextServer.TextNodes.TextNode

    timestamps()
  end

  @doc false
  def changeset(text_token, attrs) do
    text_token
    |> cast(attrs, [:content, :offset, :text_node_id, :word])
    |> validate_required([:content, :offset])
    |> cast_assoc(:text_node)
  end
end
