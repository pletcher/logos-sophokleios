defmodule TextServer.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :description, :string
    field :domain, :string
    field :homepage_copy, :string
    field :title, :string

    belongs_to :created_by, TextServer.Accounts.User

    many_to_many :project_versions, TextServer.Versions.Version,
      join_through: TextServer.Projects.Version

    many_to_many :project_users, TextServer.Accounts.User, join_through: TextServer.Projects.User

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:created_by_id, :description, :domain, :homepage_copy, :title])
    |> validate_required([:created_by_id, :description, :domain, :title])
    |> validate_format(:domain, ~r/^\w(?:[\w-]{0,61}\w)?$/)
    |> assoc_constraint(:created_by)
    |> unique_constraint(:domain)
  end
end
