defmodule TextServer.TextTokens.TextElement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_tokens_text_elements" do
    belongs_to :text_element, TextServer.TextElements.TextElement
    belongs_to :text_token, TextServer.TextTokens.TextToken

    timestamps()
  end

  @doc false
  def changeset(text_token_text_element, attrs) do
    text_token_text_element
    |> cast(attrs, [:text_element_id, :text_token_id])
    |> assoc_constraint(:text_element)
    |> assoc_constraint(:text_token)
    |> validate_required([:text_element_id, :text_token_id])
    |> unique_constraint([:text_element_id, :text_token_id])
  end
end
