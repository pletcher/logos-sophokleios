defmodule TextServer.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :description, :text
      add :domain, :string
      add :public_at, :timestamp
      add :title, :string, null: false
      add :created_by_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:projects, [:created_by_id])

    create table(:project_exemplars) do
      add :exemplar_id, references(:exemplars)
      add :project_id, references(:projects)
    end

    create table(:project_users) do
      add :project_id, references(:projects)
      add :user_id, references(:users)
    end

    project_user_type_create_query =
      "CREATE TYPE project_user_type AS ENUM ('admin', 'editor', 'user')"

    project_user_type_drop_query = "DROP TYPE project_user_type"

    execute(project_user_type_create_query, project_user_type_drop_query)

    alter table(:project_users) do
      add :project_user_type, :project_user_type, null: false
    end
  end
end
