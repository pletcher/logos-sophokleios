defmodule TextServer.Exemplars.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exemplar_pages" do
    field :page_number, :integer

    belongs_to :end_text_node, TextServer.TextNodes.TextNode
    belongs_to :exemplar, TextServer.Exemplars.Exemplar
    belongs_to :start_text_node, TextServer.TextNodes.TextNode

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [
      :end_text_node_id,
      :exemplar_id,
      :page_number,
      :start_text_node_id
    ])
    |> validate_required([
      :end_text_node_id,
      :exemplar_id,
      :page_number,
      :start_text_node_id
    ])
  end
end
