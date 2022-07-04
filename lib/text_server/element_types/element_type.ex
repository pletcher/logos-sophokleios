defmodule TextServer.ElementTypes.ElementType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "element_types" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(element_type, attrs) do
    element_type
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
