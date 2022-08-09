defmodule TextServer.Projects.Exemplar do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_exemplars" do
    belongs_to :exemplar, TextServer.Exemplars.Exemplar
    belongs_to :project, TextServer.Projects.Project

    timestamps()
  end

  @doc false
  def changeset(exemplar, attrs) do
    exemplar
    |> cast(attrs, [:exemplar_id, :project_id])
    |> validate_required([:exemplar_id, :project_id])
    |> assoc_constraint(:exemplar)
    |> assoc_constraint(:project)
  end
end
