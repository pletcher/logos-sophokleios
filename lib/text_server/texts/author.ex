defmodule TextServer.Texts.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :english_name, :string
    field :original_name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:english_name, :original_name, :slug])
    |> validate_required([:english_name, :original_name, :slug])
  end
end
