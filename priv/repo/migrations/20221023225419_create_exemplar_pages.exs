defmodule TextServer.Repo.Migrations.CreateExemplarPages do
  use Ecto.Migration

  def change do
    create table(:exemplar_pages) do
      add :page_number, :integer, null: false
      add :end_text_node_id, references(:text_nodes, on_delete: :delete_all)
      add :exemplar_id, references(:exemplars, on_delete: :delete_all)
      add :start_text_node_id, references(:text_nodes, on_delete: :delete_all)

      timestamps()
    end

    create index(:exemplar_pages, [:exemplar_id])
    create index(:exemplar_pages, [:end_text_node_id])
    create index(:exemplar_pages, [:start_text_node_id])
  end
end
