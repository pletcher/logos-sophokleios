defmodule TextServer.Repo.Migrations.AddHomepageCopyToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :homepage_copy, :text, default: ""
    end
  end
end
