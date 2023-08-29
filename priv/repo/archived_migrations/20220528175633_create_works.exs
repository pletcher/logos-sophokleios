defmodule TextServer.Repo.Migrations.CreateWorks do
  use Ecto.Migration

  def change do
    create table(:works) do
      add :description, :text
      add :english_title, :text
      add :original_title, :text
      # TODO: (charles) Warn about long URNs and allow editing by admins
      add :urn, :text, null: false
      add :text_group_id, references(:text_groups, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:works, [:text_group_id])
  end
end
