defmodule TextServer.Projects.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_users" do
    belongs_to :user, TextServer.Accounts.User
    belongs_to :project, TextServer.Projects.Project

    field :project_user_type, Ecto.Enum, values: [:admin, :editor, :user]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:project_id, :project_user_type, :user_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:project)
    |> validate_required([:project_id, :project_user_type, :user_id])
  end
end
