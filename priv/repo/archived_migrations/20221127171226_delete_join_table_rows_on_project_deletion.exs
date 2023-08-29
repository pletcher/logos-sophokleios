defmodule TextServer.Repo.Migrations.DeleteJoinTableRowsOnProjectDeletion do
  use Ecto.Migration

  def change do
    alter table(:project_exemplars) do
      modify :exemplar_id, references(:exemplars, on_delete: :delete_all),
        from: references(:exemplars, on_delete: :nothing),
        null: false

      modify :project_id, references(:projects, on_delete: :delete_all),
        from: references(:projects, on_delete: :nothing),
        null: false
    end

    alter table(:project_users) do
      modify :project_id, references(:projects, on_delete: :delete_all),
        from: references(:projects, on_delete: :nothing),
        null: false

      modify :user_id, references(:users, on_delete: :delete_all),
        from: references(:users, on_delete: :nothing),
        null: false
    end
  end
end
