defmodule TextServer.Projects.Exemplar do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_exemplars" do
    field :exemplar_id, :id
    field :project_id, :id

    timestamps()
  end

  @doc false
  def changeset(exemplar, attrs) do
    exemplar
    |> cast(attrs, [:exemplar_id, :project_id])
    |> assoc_constraint(:exemplar)
    |> assoc_constraint(:project)
  end
end
