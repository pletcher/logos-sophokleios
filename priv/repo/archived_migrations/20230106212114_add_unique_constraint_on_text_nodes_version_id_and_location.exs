defmodule TextServer.Repo.Migrations.AddUniqueConstraintOnTextNodesVersionIdAndLocation do
  use Ecto.Migration

  def change do
    create unique_index(:text_nodes, [:version_id, :location])
  end
end
