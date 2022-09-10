defmodule TextServer.Repo.Migrations.AddSearchToTextGroups do
  use Ecto.Migration

  def change do
    execute(
      """
      ALTER TABLE text_groups
      ADD COLUMN _search tsvector
      GENERATED ALWAYS AS (to_tsvector('english', coalesce(title, '')))
      STORED;
      """,
      """
      ALTER TABLE text_groups DROP COLUMN _search;
      """
    )

    create_if_not_exists index(:text_groups, [:_search], using: "GIN")
  end
end
