defmodule TextServer.Texts.TextNode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_nodes" do
    field :index, :integer
    field :location, {:array, :integer}
    field :normalized_text, :string
    field :text, :string
    field :work_id, :id
    field :_search, TextServer.Ecto.Types.TsVector

    timestamps()
  end

  @doc false
  def changeset(text_node, attrs) do
    text_node
    |> cast(attrs, [:index, :location, :normalized_text, :text])
    |> validate_required([:index, :location, :text])
  end
end
