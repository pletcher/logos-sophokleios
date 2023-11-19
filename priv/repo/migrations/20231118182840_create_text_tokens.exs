defmodule TextServer.Repo.Migrations.CreateTextTokens do
  require Logger
  use Ecto.Migration

  def up do
    create table(:text_tokens) do
      add :content, :string, null: false
      add :offset, :integer, null: false
      add :word, :string
      add :text_node_id, references(:text_nodes, on_delete: :delete_all)

      timestamps()
    end

    create index(:text_tokens, [:text_node_id])

    flush()

    TextServer.Repo.stream(TextServer.TextNodes.TextNode)
    |> Stream.each(fn text_node ->
      TextServer.TextNodes.tokenize_text_node(text_node)
      |> Enum.each(fn {token, word, offset} ->
        case TextServer.TextTokens.create_text_token(%{
               content: token,
               offset: offset,
               word: word,
               text_node_id: text_node.id
             }) do
          {:ok, text_token} -> text_token
          {:error, error} -> Logger.warning("Invalid token: #{inspect(error)}")
        end
      end)
    end)
    |> Enum.to_list()
  end

  def down do
    drop index(:text_tokens, [:text_node_id])
    drop table(:text_tokens)
  end
end
