defmodule TextServer.TextNodes.TextNode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_nodes" do
    field :location, {:array, :integer}
    field :normalized_text, :string
    field :text, :string
    field :_search, TextServer.Ecto.Types.TsVector

    belongs_to :exemplar, TextServer.Exemplars.Exemplar

    has_many :text_elements, TextServer.TextElements.TextElement, foreign_key: :start_text_node_id

    timestamps()
  end

  @doc false
  def changeset(text_node, attrs) do
    text_node
    |> cast(attrs, [:exemplar_id, :location, :text])
    |> validate_required([:location, :text])
    |> assoc_constraint(:exemplar)
  end
end
