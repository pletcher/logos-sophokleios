defmodule TextServer.TextTokensTest do
  use TextServer.DataCase

  alias TextServer.TextTokens

  describe "text_tokens" do
    alias TextServer.TextTokens.TextToken

    import TextServer.TextTokensFixtures

    @invalid_attrs %{offset: nil, content: nil}

    test "list_text_tokens/0 returns all text_tokens" do
      text_token = text_token_fixture()
      assert TextTokens.list_text_tokens() == [text_token]
    end

    test "get_text_token!/1 returns the text_token with given id" do
      text_token = text_token_fixture()
      assert TextTokens.get_text_token!(text_token.id) == text_token
    end

    test "create_text_token/1 with valid data creates a text_token" do
      valid_attrs = %{offset: 42, content: "some content"}

      assert {:ok, %TextToken{} = text_token} = TextTokens.create_text_token(valid_attrs)
      assert text_token.offset == 42
      assert text_token.content == "some content"
    end

    test "create_text_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TextTokens.create_text_token(@invalid_attrs)
    end

    test "update_text_token/2 with valid data updates the text_token" do
      text_token = text_token_fixture()
      update_attrs = %{offset: 43, content: "some updated content"}

      assert {:ok, %TextToken{} = text_token} = TextTokens.update_text_token(text_token, update_attrs)
      assert text_token.offset == 43
      assert text_token.content == "some updated content"
    end

    test "update_text_token/2 with invalid data returns error changeset" do
      text_token = text_token_fixture()
      assert {:error, %Ecto.Changeset{}} = TextTokens.update_text_token(text_token, @invalid_attrs)
      assert text_token == TextTokens.get_text_token!(text_token.id)
    end

    test "delete_text_token/1 deletes the text_token" do
      text_token = text_token_fixture()
      assert {:ok, %TextToken{}} = TextTokens.delete_text_token(text_token)
      assert_raise Ecto.NoResultsError, fn -> TextTokens.get_text_token!(text_token.id) end
    end

    test "change_text_token/1 returns a text_token changeset" do
      text_token = text_token_fixture()
      assert %Ecto.Changeset{} = TextTokens.change_text_token(text_token)
    end
  end
end
