defmodule TextServer.Repo.Migrations.CreateLanguages do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :slug, :string
      add :title, :string, null: false

      timestamps()
    end
  end
end
