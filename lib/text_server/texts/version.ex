defmodule TextServer.Texts.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "versions" do
    field :description, :string
    field :slug, :string
    field :title, :string
    field :urn, :string
    field :work_id, :id

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:description, :slug, :title, :urn])
    |> validate_required([:slug, :title, :urn])
  end
end
