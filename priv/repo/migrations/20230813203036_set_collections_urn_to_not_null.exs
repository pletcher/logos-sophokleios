defmodule TextServer.Repo.Migrations.SetCollectionsUrnToNotNull do
  use Ecto.Migration

  def change do
    execute(
      """
      alter table collections alter column urn type jsonb using (urn::jsonb)
      """
    )
  end
end
