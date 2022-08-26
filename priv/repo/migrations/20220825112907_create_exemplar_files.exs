defmodule TextServer.Repo.Migrations.CreateExemplarFiles do
  use Ecto.Migration

  def change do
    create table(:exemplar_files) do
      add :title, :string, null: false
      add :url, :string, null: false

      add :exemplar_id, references(:exemplars, on_delete: :nothing)

      timestamps()
    end

    exemplar_file_extension_type_create_query =
      "CREATE TYPE exemplar_file_extension_type AS ENUM ('docx', 'xml')"

    exemplar_file_extension_type_drop_query = "DROP TYPE exemplar_file_extension_type"

    execute(exemplar_file_extension_type_create_query, exemplar_file_extension_type_drop_query)

    alter table(:exemplar_files) do
      add :extension, :exemplar_file_extension_type, null: false
    end

    create unique_index(:exemplar_files, [:exemplar_id])
    create unique_index(:exemplar_files, [:url])
  end
end
