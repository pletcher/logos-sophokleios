defmodule TextServer.Repo.Migrations.AddUrnFragmentToTextGroups do
  use Ecto.Migration

  alias TextServer.Repo
  alias TextServer.TextGroups
  alias TextServer.Works

  def up do
    alter table(:text_groups) do
      add :urn_fragment, :string, null: true
    end

    flush()

    text_groups_by_urn = TextGroups.list_text_groups()
    |> Repo.preload(:works)
    |> Enum.group_by(&Map.get(&1, :urn))

    text_groups_by_urn
    |> Enum.each(fn {urn, text_groups} ->
      [tg | rest] = text_groups
      [_prefix, _protocol, _namespace, urn_fragment] = String.split(urn, ":")

      {:ok, text_group} = TextGroups.update_text_group(tg, %{urn_fragment: urn_fragment})

      rest |> Enum.each(fn extra_text_group ->
        extra_text_group.works
        # move all works to the first text_group
        |> Enum.each(fn work ->
          {:ok, _w} = Works.update_work(work, %{text_group_id: text_group.id})
        end)

        TextGroups.delete_text_group(extra_text_group)
      end)
    end)

    flush()

    create(unique_index(:text_groups, [:urn]))
  end

  def down do
    alter table(:text_groups) do
      remove :urn_fragment
    end
  end
end
