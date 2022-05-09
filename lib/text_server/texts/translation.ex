defmodule TextServer.Texts.Translation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "translations" do
    field :description, :string
    field :slug, :string
    field :title, :string
    field :urn, :string
    field :work_id, :id

    timestamps()
  end

  @doc false
  def changeset(translation, attrs) do
    translation
    |> cast(attrs, [:description, :slug, :title, :urn])
    |> validate_required([:slug, :title, :urn])
  end
end
