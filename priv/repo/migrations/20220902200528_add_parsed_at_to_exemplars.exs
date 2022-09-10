defmodule TextServer.Repo.Migrations.AddParsedAtToExemplars do
  use Ecto.Migration

  def change do
    alter table(:exemplars) do
      add :parsed_at, :naive_datetime
    end
  end
end
