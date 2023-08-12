defmodule TextServer.Repo.Migrations.CreateComments do
  use Ecto.Migration

  alias CTS
  alias TextServer.Comments
  alias TextServer.Repo
  alias TextServer.TextElements
  alias TextServer.TextNodes
  alias TextServer.TextNodes.TextNode

  def up do
    create table(:comments) do
      add(:attributes, :map)
      add(:content, :text, null: false)
      add(:urn, :map, null: false)
      add(:text_node_id, references(:text_nodes, on_delete: :nothing))
      add(:version_id, references(:versions, on_delete: :nothing))

      timestamps()
    end

    create(index(:comments, [:text_node_id]))
    create(index(:comments, [:version_id]))

    flush()

    alter table(:text_nodes) do
      add(:urn, :map)
    end

    flush()

    Repo.transaction(fn ->
      TextNode
      |> Repo.stream()
      |> Enum.each(fn text_node ->
        text_node = text_node |> Repo.preload(:version)

        urn_s =
          "#{CTS.URN.to_string(text_node.version.urn)}:#{Enum.join(text_node.location, ".")}"

        TextNodes.update_text_node(text_node, %{urn: urn_s})
      end)
    end)

    alter table(:text_nodes) do
      modify(:urn, :map, null: false, from: {:map, null: true})
    end

    create(unique_index(:text_nodes, :urn))

    TextElements.list_text_elements_by_type("comment")
    |> Repo.preload(start_text_node: :version)
    |> Enum.each(fn comment_el ->
      attributes = Map.get(comment_el, :attributes)
      text_node = comment_el.start_text_node
      version = text_node.version

      unless is_nil(Map.get(attributes, "urn")) do
        Comments.create_comment(%{
          attributes: comment_el.attributes,
          content: comment_el.content,
          urn: Map.get(attributes, "urn"),
          version_id: version.id,
          text_node_id: text_node.id
        })

        TextElements.delete_text_element(comment_el)
      end
    end)
  end

  def down do
    drop table(:comments)
    drop(unique_index(:text_nodes, :urn))

    alter table(:text_nodes) do
      remove(:urn)
    end
  end
end
