defmodule TextServer.Texts.TextGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_groups" do
    field :slug, :string
    field :title, :string
    field :urn, :string
    field :collection_id, :id

    timestamps()
  end

  @doc false
  def changeset(text_group, attrs) do
    text_group
    |> cast(attrs, [:slug, :title, :urn])
    |> validate_required([:slug, :title, :urn])
  end
end
