defmodule TextServer.Repo.Migrations.AddCtsUrnToTextGroups do
  use Ecto.Migration

  alias TextServer.TextGroups

  def up do
    alter table(:text_groups) do
      add :cts_urn, :map
    end

    flush()

    TextGroups.list_text_groups()
    |> Enum.each(fn text_group ->
      TextGroups.update_text_group(text_group, %{cts_urn: CTS.URN.parse(text_group.urn)})
    end)

    alter table(:text_groups) do
      modify :cts_urn, :map, null: false, from: {:map, null: true}
    end
  end

  def down do
    alter table(:text_groups) do
      remove :cts_urn
    end
  end
end
