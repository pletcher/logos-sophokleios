defmodule TextServer.Repo.Migrations.AddNToTextNodes do
  use Ecto.Migration

  def change do
    alter table(:text_nodes) do
      add :n, :integer, null: false
    end
  end
end
