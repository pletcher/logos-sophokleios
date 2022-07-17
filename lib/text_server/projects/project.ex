defmodule TextServer.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :description, :string
    field :domain, :string
    field :created_by_id, :id

    many_to_many :project_exemplars, TextServer.Exemplars.Exemplar,
      join_through: TextServer.Projects.Exemplar

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:description, :domain])
    |> validate_required([:description, :domain])
  end
end
