defmodule TextServer.Repo.Migrations.DropXmlVersions do
  use Ecto.Migration

  def change do
    drop table(:xml_versions), mode: :cascade
  end
end
