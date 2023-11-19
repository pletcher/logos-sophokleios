defmodule TextServer.TextTokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.TextTokens` context.
  """

  @doc """
  Generate a text_token.
  """
  def text_token_fixture(attrs \\ %{}) do
    {:ok, text_token} =
      attrs
      |> Enum.into(%{
        content: "some content",
        offset: 42
      })
      |> TextServer.TextTokens.create_text_token()

    text_token
  end
end
