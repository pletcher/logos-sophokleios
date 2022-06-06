defmodule TextServer.LanguagesTest do
  use TextServer.DataCase

  alias TextServer.Languages

  describe "languages" do
    alias TextServer.Languages.Language

    import TextServer.LanguagesFixtures

    @invalid_attrs %{slug: nil, title: nil}

    test "list_languages/0 returns all languages" do
      language = language_fixture()
      assert Languages.list_languages() == [language]
    end

    test "get_language!/1 returns the language with given id" do
      language = language_fixture()
      assert Languages.get_language!(language.id) == language
    end

    test "create_language/1 with valid data creates a language" do
      valid_attrs = %{slug: "some slug", title: "some title"}

      assert {:ok, %Language{} = language} = Languages.create_language(valid_attrs)
      assert language.slug == "some slug"
      assert language.title == "some title"
    end

    test "create_language/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Languages.create_language(@invalid_attrs)
    end

    test "update_language/2 with valid data updates the language" do
      language = language_fixture()
      update_attrs = %{slug: "some updated slug", title: "some updated title"}

      assert {:ok, %Language{} = language} = Languages.update_language(language, update_attrs)
      assert language.slug == "some updated slug"
      assert language.title == "some updated title"
    end

    test "update_language/2 with invalid data returns error changeset" do
      language = language_fixture()
      assert {:error, %Ecto.Changeset{}} = Languages.update_language(language, @invalid_attrs)
      assert language == Languages.get_language!(language.id)
    end

    test "delete_language/1 deletes the language" do
      language = language_fixture()
      assert {:ok, %Language{}} = Languages.delete_language(language)
      assert_raise Ecto.NoResultsError, fn -> Languages.get_language!(language.id) end
    end

    test "change_language/1 returns a language changeset" do
      language = language_fixture()
      assert %Ecto.Changeset{} = Languages.change_language(language)
    end
  end
end
