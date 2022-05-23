defmodule TextServer.Texts.Language do
  use Ecto.Schema
  import Ecto.Changeset

  schema "languages" do
    field :slug, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(language, attrs) do
    language
    |> cast(attrs, [:slug, :title])
    |> validate_required([:title])
  end
end
