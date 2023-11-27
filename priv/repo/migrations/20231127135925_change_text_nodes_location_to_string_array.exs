defmodule TextServer.Repo.Migrations.ChangeTextNodesLocationToStringArray do
  use Ecto.Migration

  def up do
    alter table(:text_nodes) do
      modify :location, {:array, :string}, from: {:array, :integer}
    end
  end

  def down do
    execute("""
    ALTER TABLE text_nodes ALTER COLUMN location TYPE integer[] USING (location::integer[]);
    """)
  end
end
