defmodule TextServer.Repo.Migrations.CreateExemplarPages do
  use Ecto.Migration

  def change do
    create table(:exemplar_pages) do
      add :page_number, :integer, null: false
      add :end_location, {:array, :integer}, null: false
      add :exemplar_id, references(:exemplars, on_delete: :delete_all)
      add :start_location, {:array, :integer}, null: false

      timestamps()
    end

    create index(:exemplar_pages, [:exemplar_id])
  end
end
