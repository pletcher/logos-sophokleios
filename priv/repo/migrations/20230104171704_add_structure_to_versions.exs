defmodule TextServer.Repo.Migrations.AddStructureToVersions do
  use Ecto.Migration

  def change do
    alter table(:versions) do
      add :structure, {:array, :string}
    end
  end
end
