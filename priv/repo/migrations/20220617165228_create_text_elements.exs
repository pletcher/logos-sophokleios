defmodule TextServer.Repo.Migrations.CreateTextElements do
  use Ecto.Migration

  def change do
    create table(:text_elements) do
      add :attributes, :map
      add :element_type_id, references(:element_types, on_delete: :nothing), null: false
      add :end_urn, :string, null: false
      add :end_text_node_id, references(:text_nodes, on_delete: :nothing), null: false
      add :start_text_node_id, references(:text_nodes, on_delete: :nothing), null: false
      add :start_urn, :string, null: false

      timestamps()
    end

    create index(:text_elements, [:end_text_node_id])
    create index(:text_elements, [:start_text_node_id])
    create index(:text_elements, [:element_type_id])
  end
end
