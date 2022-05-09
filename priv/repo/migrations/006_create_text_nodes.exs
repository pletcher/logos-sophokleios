defmodule TextServer.Repo.Migrations.CreateTextNodes do
  use Ecto.Migration

  def change do
    create table(:text_nodes) do
      add :index, :integer, null: false
      add :location, {:array, :integer}, null: false
      add :normalized_text, :string
      add :text, :string, null: false
      add :work_id, references(:works, on_delete: :nothing)
      add :_search, :tsvector

      timestamps()
    end

    create index(:text_nodes, [:work_id])
    create_if_not_exists index(:text_nodes, [:_search], using: "GIN")

    execute("""
      CREATE OR REPLACE TRIGGER text_node_search_trigger
      BEFORE INSERT OR UPDATE OF text
      ON text_nodes
      EXECUTE FUNCTION tsvector_update_trigger(_search, 'pg_catalog.english', text);
    """, """
      DROP TRIGGER IF EXISTS text_node_search_trigger ON text_nodes;
    """)

    execute("""
      CREATE OR REPLACE FUNCTION normalize_greek() RETURNS trigger AS $$
        BEGIN
          new.normalized_text := regexp_replace(normalize($1, NFD), '[\u0300-\u036f]', '', 'g');
          RETURN new;
        END;
      $$ LANGUAGE plpgsql;
    """, """
      DROP FUNCTION IF EXISTS normalize_greek();
    """)

    execute("""
      CREATE OR REPLACE TRIGGER text_node_normalized_text_trigger
      BEFORE INSERT OR UPDATE OF text
      ON text_nodes
      EXECUTE FUNCTION normalize_greek();
    """, """
      DROP TRIGGER IF EXISTS text_node_normalized_text_trigger ON text_nodes;
    """)
  end
end
