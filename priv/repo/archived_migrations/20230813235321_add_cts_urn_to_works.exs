defmodule TextServer.Repo.Migrations.AddCtsUrnToWorks do
  use Ecto.Migration

  alias TextServer.Works

  def up do
    alter table(:works) do
      add :cts_urn, :map
    end

    flush()

    Works.list_works()
    |> Enum.each(fn work ->
      Works.update_work(work, %{cts_urn: CTS.URN.parse(work.urn)})
    end)

    flush()

    alter table(:works) do
      modify :cts_urn, :map, null: false, from: {:map, null: true}
    end
  end

  def down do
    alter table(:works) do
      remove :cts_urn
    end
  end
end
