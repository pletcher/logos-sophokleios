defmodule TextServer.TextsTest do
  use TextServer.DataCase

  alias TextServer.Texts

  describe "authors" do
    alias TextServer.Texts.Author

    import TextServer.TextsFixtures

    @invalid_attrs %{english_name: nil, original_name: nil, slug: nil}

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Texts.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Texts.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      valid_attrs = %{
        english_name: "some english_name",
        original_name: "some original_name",
        slug: "some slug"
      }

      assert {:ok, %Author{} = author} = Texts.create_author(valid_attrs)
      assert author.english_name == "some english_name"
      assert author.original_name == "some original_name"
      assert author.slug == "some slug"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()

      update_attrs = %{
        english_name: "some updated english_name",
        original_name: "some updated original_name",
        slug: "some updated slug"
      }

      assert {:ok, %Author{} = author} = Texts.update_author(author, update_attrs)
      assert author.english_name == "some updated english_name"
      assert author.original_name == "some updated original_name"
      assert author.slug == "some updated slug"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_author(author, @invalid_attrs)
      assert author == Texts.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Texts.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Texts.change_author(author)
    end
  end

  describe "collections" do
    alias TextServer.Texts.Collection

    import TextServer.TextsFixtures

    @invalid_attrs %{}

    test "list_collections/0 returns all collections" do
      collection = collection_fixture()
      assert Texts.list_collections() == [collection]
    end

    test "get_collection!/1 returns the collection with given id" do
      collection = collection_fixture()
      assert Texts.get_collection!(collection.id) == collection
    end

    test "create_collection/1 with valid data creates a collection" do
      valid_attrs = %{}

      assert {:ok, %Collection{} = collection} = Texts.create_collection(valid_attrs)
    end

    test "create_collection/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_collection(@invalid_attrs)
    end

    test "update_collection/2 with valid data updates the collection" do
      collection = collection_fixture()
      update_attrs = %{}

      assert {:ok, %Collection{} = collection} = Texts.update_collection(collection, update_attrs)
    end

    test "update_collection/2 with invalid data returns error changeset" do
      collection = collection_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_collection(collection, @invalid_attrs)
      assert collection == Texts.get_collection!(collection.id)
    end

    test "delete_collection/1 deletes the collection" do
      collection = collection_fixture()
      assert {:ok, %Collection{}} = Texts.delete_collection(collection)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_collection!(collection.id) end
    end

    test "change_collection/1 returns a collection changeset" do
      collection = collection_fixture()
      assert %Ecto.Changeset{} = Texts.change_collection(collection)
    end
  end

  describe "exemplars" do
    alias TextServer.Texts.Exemplar

    import TextServer.TextsFixtures

    @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

    test "list_exemplars/0 returns all exemplars" do
      exemplar = exemplar_fixture()
      assert Texts.list_exemplars() == [exemplar]
    end

    test "get_exemplar!/1 returns the exemplar with given id" do
      exemplar = exemplar_fixture()
      assert Texts.get_exemplar!(exemplar.id) == exemplar
    end

    test "create_exemplar/1 with valid data creates a exemplar" do
      valid_attrs = %{description: "some description", slug: "some slug", title: "some title", urn: "some urn"}

      assert {:ok, %Exemplar{} = exemplar} = Texts.create_exemplar(valid_attrs)
      assert exemplar.description == "some description"
      assert exemplar.slug == "some slug"
      assert exemplar.title == "some title"
      assert exemplar.urn == "some urn"
    end

    test "create_exemplar/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_exemplar(@invalid_attrs)
    end

    test "update_exemplar/2 with valid data updates the exemplar" do
      exemplar = exemplar_fixture()
      update_attrs = %{description: "some updated description", slug: "some updated slug", title: "some updated title", urn: "some updated urn"}

      assert {:ok, %Exemplar{} = exemplar} = Texts.update_exemplar(exemplar, update_attrs)
      assert exemplar.description == "some updated description"
      assert exemplar.slug == "some updated slug"
      assert exemplar.title == "some updated title"
      assert exemplar.urn == "some updated urn"
    end

    test "update_exemplar/2 with invalid data returns error changeset" do
      exemplar = exemplar_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_exemplar(exemplar, @invalid_attrs)
      assert exemplar == Texts.get_exemplar!(exemplar.id)
    end

    test "delete_exemplar/1 deletes the exemplar" do
      exemplar = exemplar_fixture()
      assert {:ok, %Exemplar{}} = Texts.delete_exemplar(exemplar)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_exemplar!(exemplar.id) end
    end

    test "change_exemplar/1 returns a exemplar changeset" do
      exemplar = exemplar_fixture()
      assert %Ecto.Changeset{} = Texts.change_exemplar(exemplar)
    end
  end

  describe "languages" do
    alias TextServer.Texts.Language

    import TextServer.TextsFixtures

    @invalid_attrs %{slug: nil, title: nil}

    test "list_languages/0 returns all languages" do
      language = language_fixture()
      assert Texts.list_languages() == [language]
    end

    test "get_language!/1 returns the language with given id" do
      language = language_fixture()
      assert Texts.get_language!(language.id) == language
    end

    test "create_language/1 with valid data creates a language" do
      valid_attrs = %{slug: "some slug", title: "some title"}

      assert {:ok, %Language{} = language} = Texts.create_language(valid_attrs)
      assert language.slug == "some slug"
      assert language.title == "some title"
    end

    test "create_language/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_language(@invalid_attrs)
    end

    test "update_language/2 with valid data updates the language" do
      language = language_fixture()
      update_attrs = %{slug: "some updated slug", title: "some updated title"}

      assert {:ok, %Language{} = language} = Texts.update_language(language, update_attrs)
      assert language.slug == "some updated slug"
      assert language.title == "some updated title"
    end

    test "update_language/2 with invalid data returns error changeset" do
      language = language_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_language(language, @invalid_attrs)
      assert language == Texts.get_language!(language.id)
    end

    test "delete_language/1 deletes the language" do
      language = language_fixture()
      assert {:ok, %Language{}} = Texts.delete_language(language)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_language!(language.id) end
    end

    test "change_language/1 returns a language changeset" do
      language = language_fixture()
      assert %Ecto.Changeset{} = Texts.change_language(language)
    end
  end

  describe "refs_decls" do
    alias TextServer.Texts.RefsDecl

    import TextServer.TextsFixtures

    @invalid_attrs %{description: nil, label: nil, match_pattern: nil, replacement_pattern: nil, slug: nil, structure_index: nil, urn: nil}

    test "list_refs_decls/0 returns all refs_decls" do
      refs_decl = refs_decl_fixture()
      assert Texts.list_refs_decls() == [refs_decl]
    end

    test "get_refs_decl!/1 returns the refs_decl with given id" do
      refs_decl = refs_decl_fixture()
      assert Texts.get_refs_decl!(refs_decl.id) == refs_decl
    end

    test "create_refs_decl/1 with valid data creates a refs_decl" do
      valid_attrs = %{description: "some description", label: "some label", match_pattern: "some match_pattern", replacement_pattern: "some replacement_pattern", slug: "some slug", structure_index: 42, urn: "some urn"}

      assert {:ok, %RefsDecl{} = refs_decl} = Texts.create_refs_decl(valid_attrs)
      assert refs_decl.description == "some description"
      assert refs_decl.label == "some label"
      assert refs_decl.match_pattern == "some match_pattern"
      assert refs_decl.replacement_pattern == "some replacement_pattern"
      assert refs_decl.slug == "some slug"
      assert refs_decl.structure_index == 42
      assert refs_decl.urn == "some urn"
    end

    test "create_refs_decl/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_refs_decl(@invalid_attrs)
    end

    test "update_refs_decl/2 with valid data updates the refs_decl" do
      refs_decl = refs_decl_fixture()
      update_attrs = %{description: "some updated description", label: "some updated label", match_pattern: "some updated match_pattern", replacement_pattern: "some updated replacement_pattern", slug: "some updated slug", structure_index: 43, urn: "some updated urn"}

      assert {:ok, %RefsDecl{} = refs_decl} = Texts.update_refs_decl(refs_decl, update_attrs)
      assert refs_decl.description == "some updated description"
      assert refs_decl.label == "some updated label"
      assert refs_decl.match_pattern == "some updated match_pattern"
      assert refs_decl.replacement_pattern == "some updated replacement_pattern"
      assert refs_decl.slug == "some updated slug"
      assert refs_decl.structure_index == 43
      assert refs_decl.urn == "some updated urn"
    end

    test "update_refs_decl/2 with invalid data returns error changeset" do
      refs_decl = refs_decl_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_refs_decl(refs_decl, @invalid_attrs)
      assert refs_decl == Texts.get_refs_decl!(refs_decl.id)
    end

    test "delete_refs_decl/1 deletes the refs_decl" do
      refs_decl = refs_decl_fixture()
      assert {:ok, %RefsDecl{}} = Texts.delete_refs_decl(refs_decl)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_refs_decl!(refs_decl.id) end
    end

    test "change_refs_decl/1 returns a refs_decl changeset" do
      refs_decl = refs_decl_fixture()
      assert %Ecto.Changeset{} = Texts.change_refs_decl(refs_decl)
    end
  end

  describe "text_groups" do
    alias TextServer.Texts.TextGroup

    import TextServer.TextsFixtures

    @invalid_attrs %{slug: nil, title: nil, urn: nil}

    test "list_text_groups/0 returns all text_groups" do
      text_group = text_group_fixture()
      assert Texts.list_text_groups() == [text_group]
    end

    test "get_text_group!/1 returns the text_group with given id" do
      text_group = text_group_fixture()
      assert Texts.get_text_group!(text_group.id) == text_group
    end

    test "create_text_group/1 with valid data creates a text_group" do
      valid_attrs = %{slug: "some slug", title: "some title", urn: "some urn"}

      assert {:ok, %TextGroup{} = text_group} = Texts.create_text_group(valid_attrs)
      assert text_group.slug == "some slug"
      assert text_group.title == "some title"
      assert text_group.urn == "some urn"
    end

    test "create_text_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_text_group(@invalid_attrs)
    end

    test "update_text_group/2 with valid data updates the text_group" do
      text_group = text_group_fixture()
      update_attrs = %{slug: "some updated slug", title: "some updated title", urn: "some updated urn"}

      assert {:ok, %TextGroup{} = text_group} = Texts.update_text_group(text_group, update_attrs)
      assert text_group.slug == "some updated slug"
      assert text_group.title == "some updated title"
      assert text_group.urn == "some updated urn"
    end

    test "update_text_group/2 with invalid data returns error changeset" do
      text_group = text_group_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_text_group(text_group, @invalid_attrs)
      assert text_group == Texts.get_text_group!(text_group.id)
    end

    test "delete_text_group/1 deletes the text_group" do
      text_group = text_group_fixture()
      assert {:ok, %TextGroup{}} = Texts.delete_text_group(text_group)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_text_group!(text_group.id) end
    end

    test "change_text_group/1 returns a text_group changeset" do
      text_group = text_group_fixture()
      assert %Ecto.Changeset{} = Texts.change_text_group(text_group)
    end
  end

  describe "text_nodes" do
    alias TextServer.Texts.TextNode

    import TextServer.TextsFixtures

    @invalid_attrs %{index: nil, location: nil, normalized_text: nil, text: nil}

    test "list_text_nodes/0 returns all text_nodes" do
      text_node = text_node_fixture()
      assert Texts.list_text_nodes() == [text_node]
    end

    test "get_text_node!/1 returns the text_node with given id" do
      text_node = text_node_fixture()
      assert Texts.get_text_node!(text_node.id) == text_node
    end

    test "create_text_node/1 with valid data creates a text_node" do
      valid_attrs = %{index: 42, location: [], normalized_text: "some normalized_text", text: "some text"}

      assert {:ok, %TextNode{} = text_node} = Texts.create_text_node(valid_attrs)
      assert text_node.index == 42
      assert text_node.location == []
      assert text_node.normalized_text == "some normalized_text"
      assert text_node.text == "some text"
    end

    test "create_text_node/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_text_node(@invalid_attrs)
    end

    test "update_text_node/2 with valid data updates the text_node" do
      text_node = text_node_fixture()
      update_attrs = %{index: 43, location: [], normalized_text: "some updated normalized_text", text: "some updated text"}

      assert {:ok, %TextNode{} = text_node} = Texts.update_text_node(text_node, update_attrs)
      assert text_node.index == 43
      assert text_node.location == []
      assert text_node.normalized_text == "some updated normalized_text"
      assert text_node.text == "some updated text"
    end

    test "update_text_node/2 with invalid data returns error changeset" do
      text_node = text_node_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_text_node(text_node, @invalid_attrs)
      assert text_node == Texts.get_text_node!(text_node.id)
    end

    test "delete_text_node/1 deletes the text_node" do
      text_node = text_node_fixture()
      assert {:ok, %TextNode{}} = Texts.delete_text_node(text_node)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_text_node!(text_node.id) end
    end

    test "change_text_node/1 returns a text_node changeset" do
      text_node = text_node_fixture()
      assert %Ecto.Changeset{} = Texts.change_text_node(text_node)
    end
  end

  describe "translations" do
    alias TextServer.Texts.Translation

    import TextServer.TextsFixtures

    @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

    test "list_translations/0 returns all translations" do
      translation = translation_fixture()
      assert Texts.list_translations() == [translation]
    end

    test "get_translation!/1 returns the translation with given id" do
      translation = translation_fixture()
      assert Texts.get_translation!(translation.id) == translation
    end

    test "create_translation/1 with valid data creates a translation" do
      valid_attrs = %{description: "some description", slug: "some slug", title: "some title", urn: "some urn"}

      assert {:ok, %Translation{} = translation} = Texts.create_translation(valid_attrs)
      assert translation.description == "some description"
      assert translation.slug == "some slug"
      assert translation.title == "some title"
      assert translation.urn == "some urn"
    end

    test "create_translation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_translation(@invalid_attrs)
    end

    test "update_translation/2 with valid data updates the translation" do
      translation = translation_fixture()
      update_attrs = %{description: "some updated description", slug: "some updated slug", title: "some updated title", urn: "some updated urn"}

      assert {:ok, %Translation{} = translation} = Texts.update_translation(translation, update_attrs)
      assert translation.description == "some updated description"
      assert translation.slug == "some updated slug"
      assert translation.title == "some updated title"
      assert translation.urn == "some updated urn"
    end

    test "update_translation/2 with invalid data returns error changeset" do
      translation = translation_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_translation(translation, @invalid_attrs)
      assert translation == Texts.get_translation!(translation.id)
    end

    test "delete_translation/1 deletes the translation" do
      translation = translation_fixture()
      assert {:ok, %Translation{}} = Texts.delete_translation(translation)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_translation!(translation.id) end
    end

    test "change_translation/1 returns a translation changeset" do
      translation = translation_fixture()
      assert %Ecto.Changeset{} = Texts.change_translation(translation)
    end
  end

  describe "versions" do
    alias TextServer.Texts.Version

    import TextServer.TextsFixtures

    @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

    test "list_versions/0 returns all versions" do
      version = version_fixture()
      assert Texts.list_versions() == [version]
    end

    test "get_version!/1 returns the version with given id" do
      version = version_fixture()
      assert Texts.get_version!(version.id) == version
    end

    test "create_version/1 with valid data creates a version" do
      valid_attrs = %{description: "some description", slug: "some slug", title: "some title", urn: "some urn"}

      assert {:ok, %Version{} = version} = Texts.create_version(valid_attrs)
      assert version.description == "some description"
      assert version.slug == "some slug"
      assert version.title == "some title"
      assert version.urn == "some urn"
    end

    test "create_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_version(@invalid_attrs)
    end

    test "update_version/2 with valid data updates the version" do
      version = version_fixture()
      update_attrs = %{description: "some updated description", slug: "some updated slug", title: "some updated title", urn: "some updated urn"}

      assert {:ok, %Version{} = version} = Texts.update_version(version, update_attrs)
      assert version.description == "some updated description"
      assert version.slug == "some updated slug"
      assert version.title == "some updated title"
      assert version.urn == "some updated urn"
    end

    test "update_version/2 with invalid data returns error changeset" do
      version = version_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_version(version, @invalid_attrs)
      assert version == Texts.get_version!(version.id)
    end

    test "delete_version/1 deletes the version" do
      version = version_fixture()
      assert {:ok, %Version{}} = Texts.delete_version(version)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_version!(version.id) end
    end

    test "change_version/1 returns a version changeset" do
      version = version_fixture()
      assert %Ecto.Changeset{} = Texts.change_version(version)
    end
  end

  describe "works" do
    alias TextServer.Texts.Work

    import TextServer.TextsFixtures

    @invalid_attrs %{description: nil, english_title: nil, filemd5hash: nil, filename: nil, form: nil, full_urn: nil, label: nil, original_title: nil, slug: nil, structure: nil, urn: nil, work_type: nil}

    test "list_works/0 returns all works" do
      work = work_fixture()
      assert Texts.list_works() == [work]
    end

    test "get_work!/1 returns the work with given id" do
      work = work_fixture()
      assert Texts.get_work!(work.id) == work
    end

    test "create_work/1 with valid data creates a work" do
      valid_attrs = %{description: "some description", english_title: "some english_title", filemd5hash: "some filemd5hash", filename: "some filename", form: "some form", full_urn: "some full_urn", label: "some label", original_title: "some original_title", slug: "some slug", structure: "some structure", urn: "some urn", work_type: "some work_type"}

      assert {:ok, %Work{} = work} = Texts.create_work(valid_attrs)
      assert work.description == "some description"
      assert work.english_title == "some english_title"
      assert work.filemd5hash == "some filemd5hash"
      assert work.filename == "some filename"
      assert work.form == "some form"
      assert work.full_urn == "some full_urn"
      assert work.label == "some label"
      assert work.original_title == "some original_title"
      assert work.slug == "some slug"
      assert work.structure == "some structure"
      assert work.urn == "some urn"
      assert work.work_type == "some work_type"
    end

    test "create_work/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_work(@invalid_attrs)
    end

    test "update_work/2 with valid data updates the work" do
      work = work_fixture()
      update_attrs = %{description: "some updated description", english_title: "some updated english_title", filemd5hash: "some updated filemd5hash", filename: "some updated filename", form: "some updated form", full_urn: "some updated full_urn", label: "some updated label", original_title: "some updated original_title", slug: "some updated slug", structure: "some updated structure", urn: "some updated urn", work_type: "some updated work_type"}

      assert {:ok, %Work{} = work} = Texts.update_work(work, update_attrs)
      assert work.description == "some updated description"
      assert work.english_title == "some updated english_title"
      assert work.filemd5hash == "some updated filemd5hash"
      assert work.filename == "some updated filename"
      assert work.form == "some updated form"
      assert work.full_urn == "some updated full_urn"
      assert work.label == "some updated label"
      assert work.original_title == "some updated original_title"
      assert work.slug == "some updated slug"
      assert work.structure == "some updated structure"
      assert work.urn == "some updated urn"
      assert work.work_type == "some updated work_type"
    end

    test "update_work/2 with invalid data returns error changeset" do
      work = work_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_work(work, @invalid_attrs)
      assert work == Texts.get_work!(work.id)
    end

    test "delete_work/1 deletes the work" do
      work = work_fixture()
      assert {:ok, %Work{}} = Texts.delete_work(work)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_work!(work.id) end
    end

    test "change_work/1 returns a work changeset" do
      work = work_fixture()
      assert %Ecto.Changeset{} = Texts.change_work(work)
    end
  end

  describe "authors" do
    alias TextServer.Texts.Author

    import TextServer.TextsFixtures

    @invalid_attrs %{english_name: nil, original_name: nil, slug: nil}

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Texts.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Texts.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      valid_attrs = %{english_name: "some english_name", original_name: "some original_name", slug: "some slug"}

      assert {:ok, %Author{} = author} = Texts.create_author(valid_attrs)
      assert author.english_name == "some english_name"
      assert author.original_name == "some original_name"
      assert author.slug == "some slug"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Texts.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()
      update_attrs = %{english_name: "some updated english_name", original_name: "some updated original_name", slug: "some updated slug"}

      assert {:ok, %Author{} = author} = Texts.update_author(author, update_attrs)
      assert author.english_name == "some updated english_name"
      assert author.original_name == "some updated original_name"
      assert author.slug == "some updated slug"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} = Texts.update_author(author, @invalid_attrs)
      assert author == Texts.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Texts.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Texts.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Texts.change_author(author)
    end
  end
end
