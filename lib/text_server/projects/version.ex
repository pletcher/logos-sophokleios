defmodule TextServer.Projects.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_versions" do
    belongs_to :version, TextServer.Versions.Version
    belongs_to :project, TextServer.Projects.Project

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:version_id, :project_id])
    |> validate_required([:version_id, :project_id])
    |> assoc_constraint(:version)
    |> assoc_constraint(:project)
  end
end
