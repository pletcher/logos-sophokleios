defmodule TextServer.Repo.Migrations.AddTeiHeaderToExemplars do
  use Ecto.Migration

  def change do
    alter table("exemplars") do
      add :tei_header, :map, default: %{}
    end
  end
end
