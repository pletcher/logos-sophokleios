defmodule TextServer.TextElements.TextElement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_elements" do
    field :attributes, :map
    field :end_urn, :string
    field :start_urn, :string

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
      :end_urn,
      :start_urn
    ])
    |> validate_required([:attributes, :end_urn, :start_urn])
    |> assoc_constraint([:element_type, :end_text_node, :start_text_node])
  end
end
