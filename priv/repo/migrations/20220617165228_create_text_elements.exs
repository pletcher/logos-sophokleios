defmodule TextServer.Repo.Migrations.CreateTextElements do
  use Ecto.Migration

  def change do
    create table(:text_elements) do
      add :attributes, :map
      add :end_offset, :integer, default: 0
      add :start_offset, :integer, default: 0
      add :element_type_id, references(:element_types, on_delete: :nothing), null: false
      add :end_text_node_id, references(:text_nodes, on_delete: :delete_all), null: false
      add :start_text_node_id, references(:text_nodes, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:text_elements, [:end_text_node_id])
    create index(:text_elements, [:start_text_node_id])
    create index(:text_elements, [:element_type_id])
  end
end
