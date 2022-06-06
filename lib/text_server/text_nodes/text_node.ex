defmodule TextServer.TextNodes.TextNode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_nodes" do
    field :location, {:array, :integer}
    field :normalized_text, :string
    field :text, :string
    field :_search, TextServer.Ecto.Types.TsVector

    belongs_to :exemplar, TextServer.Exemplars.Exemplar

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
