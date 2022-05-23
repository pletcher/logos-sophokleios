defmodule TextServer.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :english_name, :string
      add :original_name, :string, null: false
      add :slug, :string, unique: true

      timestamps()
    end
  end
end
