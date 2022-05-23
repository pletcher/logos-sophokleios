defmodule TextServer.Texts.Exemplar do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exemplars" do
    field :description, :string
    field :slug, :string
    field :title, :string
    field :urn, :string
    field :work_id, :id

    timestamps()
  end

  @doc false
  def changeset(exemplar, attrs) do
    exemplar
    |> cast(attrs, [:description, :slug, :title, :urn])
    |> validate_required([:title, :urn])
    |> unique_constraint([:title, :urn, :work_id])
  end
end
