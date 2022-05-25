defmodule TextServer.Repo.Migrations.CreateWorks do
  use Ecto.Migration

  def change do
    create table(:works) do
      add :description, :string
      add :english_title, :string, null: false
      add :filemd5hash, :string, null: false
      add :filename, :string, null: false
      add :form, :string
      add :full_urn, :string
      add :label, :string
      add :original_title, :string
      add :slug, :string, null: false
      add :structure, :string
      add :urn, :string, null: false
      add :work_type, :string
      add :author_id, references(:authors, on_delete: :nothing)
      add :language_id, references(:languages, on_delete: :nothing)
      add :text_group_id, references(:text_groups, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:works, [:author_id])
    create index(:works, [:language_id])
    create index(:works, [:text_group_id])
    create unique_index(:works, [:filemd5hash, :text_group_id])
  end
end
