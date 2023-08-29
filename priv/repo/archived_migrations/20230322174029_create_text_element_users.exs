defmodule TextServer.Repo.Migrations.CreateTextElementUsers do
  use Ecto.Migration

  def change do
    create table(:text_element_users) do
      add :text_element_id, references(:text_elements, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:text_element_users, [:text_element_id])
    create index(:text_element_users, [:user_id])
    create unique_index(:text_element_users, [:text_element_id, :user_id])
  end
end
