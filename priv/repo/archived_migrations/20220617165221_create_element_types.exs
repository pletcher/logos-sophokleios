defmodule TextServer.Repo.Migrations.CreateElementTypes do
  use Ecto.Migration

  def change do
    create table(:element_types) do
      add :name, :string, null: false
      add :description, :string

      timestamps()
    end

    create unique_index(:element_types, [:name])
  end
end
