defmodule TextServer.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :description, :string
    field :domain, :string
    field :title, :string

    belongs_to :created_by, TextServer.Accounts.User

    many_to_many :project_exemplars, TextServer.Exemplars.Exemplar,
      join_through: TextServer.Projects.Exemplar

    many_to_many :project_users, TextServer.Accounts.User, join_through: TextServer.Projects.User

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:created_by_id, :description, :domain, :title])
    |> validate_required([:description, :domain, :title])
    |> assoc_constraint(:created_by)
    |> unique_constraint(:domain)
  end
end
