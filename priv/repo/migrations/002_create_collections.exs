defmodule TextServer.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :repository, :string, null: false, unique: true
      add :slug, :string, unique: true
      add :title, :string, null: false
      add :urn, :string, null: false

      timestamps()
    end
  end
end
