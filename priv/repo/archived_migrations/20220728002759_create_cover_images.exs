defmodule TextServer.Repo.Migrations.CreateCoverImages do
  use Ecto.Migration

  def change do
    create table(:cover_images) do
      add :attribution_name, :string, null: false
      add :attribution_source, :string, null: false
      add :attribution_source_url, :string, null: false
      add :attribution_url, :string, null: false
      add :image_url, :string, null: false

      timestamps()
    end

    create unique_index(:cover_images, [:attribution_url])
    create unique_index(:cover_images, [:image_url])

    create table(:project_cover_images) do
      add :cover_image_id, references(:cover_images)
      add :project_id, references(:projects)
    end
  end
end
