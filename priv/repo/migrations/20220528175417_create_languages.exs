defmodule TextServer.Repo.Migrations.CreateLanguages do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :slug, :string, null: false
      add :title, :string, null: false

      timestamps()
    end

    create unique_index(:languages, [:title])
    create unique_index(:languages, [:slug])
  end
end
