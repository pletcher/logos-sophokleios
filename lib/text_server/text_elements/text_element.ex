defmodule TextServer.TextElements.TextElement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_elements" do
    field :attributes, :map
    field :end_offset, :integer
    field :start_offset, :integer

    belongs_to :element_type, TextServer.ElementTypes.ElementType
    belongs_to :end_text_node, TextSrver.TextNodes.TextNode
    belongs_to :start_text_node, TextServer.TextNodes.TextNode

    timestamps()
  end

  @doc false
  def changeset(text_element, attrs) do
    text_element
    |> cast(attrs, [
      :attributes,
      :element_type_id,
      :end_offset,
      :end_text_node_id,
      :start_offset,
      :start_text_node_id
    ])
    |> validate_required([:attributes, :end_offset, :start_offset])
    |> assoc_constraint(:element_type)
    |> assoc_constraint(:end_text_node)
    |> assoc_constraint(:start_text_node)
  end
end
