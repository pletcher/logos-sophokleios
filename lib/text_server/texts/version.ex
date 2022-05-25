defmodule TextServer.Texts.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "versions" do
    field :description, :string
    field :slug, :string
    field :title, :string
    field :urn, :string

    belongs_to :work, TextServer.Texts.Work

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:description, :slug, :title, :urn])
    |> validate_required([:title, :urn])
    |> unique_constraint([:title, :urn, :work_id])
  end
end
