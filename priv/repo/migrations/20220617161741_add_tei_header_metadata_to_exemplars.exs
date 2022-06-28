defmodule TextServer.Repo.Migrations.AddTeiHeaderMetadataToExemplars do
  use Ecto.Migration

  def change do
    alter table("exemplars") do
      add :tei_header_metadata, :map, default: %{}
    end
  end
end
