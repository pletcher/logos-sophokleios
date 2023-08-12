defmodule TextServer.Repo.Migrations.AddUrnToTextNodes do
  use Ecto.Migration

  alias CTS
  alias TextServer.Repo
  alias TextServer.TextNodes
  alias TextServer.TextNodes.TextNode

  def change do
    # no changes -- migration moved to priv/repo/migrations/20230809212743_create_comments.exs
    # for deployment
  end

  # def up do
  #   alter table(:text_nodes) do
  #     add(:urn, :map)
  #   end

  #   flush()

  #   Repo.transaction(fn ->
  #     TextNode
  #     |> Repo.stream()
  #     |> Enum.each(fn text_node ->
  #       text_node = text_node |> Repo.preload(:version)

  #       urn_s =
  #         "#{CTS.URN.to_string(text_node.version.urn)}:#{Enum.join(text_node.location, ".")}"

  #       TextNodes.update_text_node(text_node, %{urn: urn_s})
  #     end)
  #   end)

  #   alter table(:text_nodes) do
  #     modify(:urn, :map, null: false, from: {:map, null: true})
  #   end

  #   create(unique_index(:text_nodes, :urn))
  # end

  # def down do
  #   drop(unique_index(:text_nodes, :urn))

  #   alter table(:text_nodes) do
  #     remove(:urn)
  #   end
  # end
end
