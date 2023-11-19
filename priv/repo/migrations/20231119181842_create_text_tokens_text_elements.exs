defmodule TextServer.Repo.Migrations.CreateTextTokensTextElements do
  use Ecto.Migration

  def up do
    create table(:text_tokens_text_elements) do
      add :text_element_id, references(:text_elements, on_delete: :delete_all)
      add :text_token_id, references(:text_tokens, on_delete: :delete_all)

      timestamps()
    end

    create index(:text_tokens_text_elements, [:text_element_id])
    create index(:text_tokens_text_elements, [:text_token_id])
    create unique_index(:text_tokens_text_elements, [:text_element_id, :text_token_id])

    flush()

    TextServer.Repo.stream(TextServer.TextElements.TextElement)
    |> Stream.each(fn te ->
      text_element =
        TextServer.Repo.preload(te,
          start_text_node: [:text_tokens],
          end_text_node: [:text_tokens]
        )

      start_text_node = text_element.start_text_node
      end_text_node = text_element.end_text_node

      to_create =
        if start_text_node == end_text_node do
          start_text_node.text_tokens
          |> Enum.filter(fn token ->
            token.offset in text_element.start_offset..text_element.end_offset
          end)
        else
          start_element_tokens =
            start_text_node.text_tokens
            |> Enum.filter(fn token ->
              token.offset in text_element.start_offset..String.length(start_text_node.text)
            end)

          end_element_tokens =
            end_text_node.text_tokens
            |> Enum.filter(fn token ->
              token.offset in 0..text_element.end_offset
            end)

          Enum.concat(start_element_tokens, end_element_tokens)
        end

      to_create
      |> Enum.each(fn token ->
        TextServer.TextTokens.create_text_token_text_element(%{
          text_element_id: text_element.id,
          text_token_id: token.id
        })
      end)
    end)
    |> Enum.to_list()
  end

  def down do
    drop unique_index(:text_tokens_text_elements, [:text_element_id, :text_token_id])
    drop index(:text_tokens_text_elements, [:text_element_id])
    drop index(:text_tokens_text_elements, [:text_token_id])

    drop table(:text_tokens_text_elements)
  end
end
