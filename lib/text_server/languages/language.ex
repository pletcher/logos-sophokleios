defmodule TextServer.Languages.Language do
  use Ecto.Schema
  import Ecto.Changeset

  schema "languages" do
    field :slug, :string
    field :title, :string

    has_many :versions, TextServer.Versions.Version

    timestamps()
  end

  @doc false
  def changeset(language, attrs) do
    language
    |> cast(attrs, [:slug, :title])
    |> validate_required([:slug, :title])
    |> unique_constraint(:title)
    |> unique_constraint(:slug)
  end
end
