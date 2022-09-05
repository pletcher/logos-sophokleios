defmodule TextServer.Repo.Migrations.AddSearchToWorks do
  use Ecto.Migration

  def change do
  	# we're using a generated column
  	# see https://www.postgresql.org/docs/12/ddl-generated-columns.html
  	execute(
  	  """
  	  ALTER TABLE works
  	  ADD COLUMN _search tsvector
  	  GENERATED ALWAYS AS (to_tsvector('english',
  	  	coalesce(english_title, '') ||
  	  	' ' ||
  	  	coalesce(description, '')
  	  )) STORED;
  	  """,
  	  """
  	  ALTER TABLE works DROP COLUMN _search;
  	  """
  	)
  	create_if_not_exists index(:works, [:_search], using: "GIN")
  end
end
