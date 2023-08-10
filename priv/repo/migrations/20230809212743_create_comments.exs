defmodule TextServer.Repo.Migrations.CreateComments do
  use Ecto.Migration

  alias TextServer.Comments
  alias TextServer.Repo
  alias TextServer.TextElements

  def change do
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
end
