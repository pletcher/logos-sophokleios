defmodule TextServer.Projects.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_users" do
    field :user_id, :id
    field :project_id, :id
    field :project_user_type, Ecto.Enum, values: [:admin, :editor, :user]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:project_id, :project_user_type, :user_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:project)
    |> validate_required(:project_user_type)
  end
end
