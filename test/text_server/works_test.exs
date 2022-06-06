defmodule TextServer.WorksTest do
  use TextServer.DataCase

  alias TextServer.Works

  describe "works" do
    alias TextServer.Works.Work

    import TextServer.WorksFixtures

    @invalid_attrs %{description: nil, english_title: nil, filemd5hash: nil, filename: nil, form: nil, full_urn: nil, label: nil, original_title: nil, slug: nil, structure: nil, urn: nil, work_type: nil}

    test "list_works/0 returns all works" do
      work = work_fixture()
      assert Works.list_works() == [work]
    end

    test "get_work!/1 returns the work with given id" do
      work = work_fixture()
      assert Works.get_work!(work.id) == work
    end

    test "create_work/1 with valid data creates a work" do
      valid_attrs = %{description: "some description", english_title: "some english_title", filemd5hash: "some filemd5hash", filename: "some filename", form: "some form", full_urn: "some full_urn", label: "some label", original_title: "some original_title", slug: "some slug", structure: "some structure", urn: "some urn", work_type: :edition}

      assert {:ok, %Work{} = work} = Works.create_work(valid_attrs)
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
      assert work.work_type == :edition
    end

    test "create_work/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Works.create_work(@invalid_attrs)
    end

    test "update_work/2 with valid data updates the work" do
      work = work_fixture()
      update_attrs = %{description: "some updated description", english_title: "some updated english_title", filemd5hash: "some updated filemd5hash", filename: "some updated filename", form: "some updated form", full_urn: "some updated full_urn", label: "some updated label", original_title: "some updated original_title", slug: "some updated slug", structure: "some updated structure", urn: "some updated urn", work_type: :translation}

      assert {:ok, %Work{} = work} = Works.update_work(work, update_attrs)
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
      assert work.work_type == :translation
    end

    test "update_work/2 with invalid data returns error changeset" do
      work = work_fixture()
      assert {:error, %Ecto.Changeset{}} = Works.update_work(work, @invalid_attrs)
      assert work == Works.get_work!(work.id)
    end

    test "delete_work/1 deletes the work" do
      work = work_fixture()
      assert {:ok, %Work{}} = Works.delete_work(work)
      assert_raise Ecto.NoResultsError, fn -> Works.get_work!(work.id) end
    end

    test "change_work/1 returns a work changeset" do
      work = work_fixture()
      assert %Ecto.Changeset{} = Works.change_work(work)
    end
  end

  describe "editions" do
    alias TextServer.Works.Edition

    import TextServer.WorksFixtures

    @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

    test "list_editions/0 returns all editions" do
      edition = edition_fixture()
      assert Works.list_editions() == [edition]
    end

    test "get_edition!/1 returns the edition with given id" do
      edition = edition_fixture()
      assert Works.get_edition!(edition.id) == edition
    end

    test "create_edition/1 with valid data creates a edition" do
      valid_attrs = %{description: "some description", slug: "some slug", title: "some title", urn: "some urn"}

      assert {:ok, %Edition{} = edition} = Works.create_edition(valid_attrs)
      assert edition.description == "some description"
      assert edition.slug == "some slug"
      assert edition.title == "some title"
      assert edition.urn == "some urn"
    end

    test "create_edition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Works.create_edition(@invalid_attrs)
    end

    test "update_edition/2 with valid data updates the edition" do
      edition = edition_fixture()
      update_attrs = %{description: "some updated description", slug: "some updated slug", title: "some updated title", urn: "some updated urn"}

      assert {:ok, %Edition{} = edition} = Works.update_edition(edition, update_attrs)
      assert edition.description == "some updated description"
      assert edition.slug == "some updated slug"
      assert edition.title == "some updated title"
      assert edition.urn == "some updated urn"
    end

    test "update_edition/2 with invalid data returns error changeset" do
      edition = edition_fixture()
      assert {:error, %Ecto.Changeset{}} = Works.update_edition(edition, @invalid_attrs)
      assert edition == Works.get_edition!(edition.id)
    end

    test "delete_edition/1 deletes the edition" do
      edition = edition_fixture()
      assert {:ok, %Edition{}} = Works.delete_edition(edition)
      assert_raise Ecto.NoResultsError, fn -> Works.get_edition!(edition.id) end
    end

    test "change_edition/1 returns a edition changeset" do
      edition = edition_fixture()
      assert %Ecto.Changeset{} = Works.change_edition(edition)
    end
  end

  describe "translations" do
    alias TextServer.Works.Translation

    import TextServer.WorksFixtures

    @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

    test "list_translations/0 returns all translations" do
      translation = translation_fixture()
      assert Works.list_translations() == [translation]
    end

    test "get_translation!/1 returns the translation with given id" do
      translation = translation_fixture()
      assert Works.get_translation!(translation.id) == translation
    end

    test "create_translation/1 with valid data creates a translation" do
      valid_attrs = %{description: "some description", slug: "some slug", title: "some title", urn: "some urn"}

      assert {:ok, %Translation{} = translation} = Works.create_translation(valid_attrs)
      assert translation.description == "some description"
      assert translation.slug == "some slug"
      assert translation.title == "some title"
      assert translation.urn == "some urn"
    end

    test "create_translation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Works.create_translation(@invalid_attrs)
    end

    test "update_translation/2 with valid data updates the translation" do
      translation = translation_fixture()
      update_attrs = %{description: "some updated description", slug: "some updated slug", title: "some updated title", urn: "some updated urn"}

      assert {:ok, %Translation{} = translation} = Works.update_translation(translation, update_attrs)
      assert translation.description == "some updated description"
      assert translation.slug == "some updated slug"
      assert translation.title == "some updated title"
      assert translation.urn == "some updated urn"
    end

    test "update_translation/2 with invalid data returns error changeset" do
      translation = translation_fixture()
      assert {:error, %Ecto.Changeset{}} = Works.update_translation(translation, @invalid_attrs)
      assert translation == Works.get_translation!(translation.id)
    end

    test "delete_translation/1 deletes the translation" do
      translation = translation_fixture()
      assert {:ok, %Translation{}} = Works.delete_translation(translation)
      assert_raise Ecto.NoResultsError, fn -> Works.get_translation!(translation.id) end
    end

    test "change_translation/1 returns a translation changeset" do
      translation = translation_fixture()
      assert %Ecto.Changeset{} = Works.change_translation(translation)
    end
  end

  describe "versions" do
    alias TextServer.Works.Version

    import TextServer.WorksFixtures

    @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

    test "list_versions/0 returns all versions" do
      version = version_fixture()
      assert Works.list_versions() == [version]
    end

    test "get_version!/1 returns the version with given id" do
      version = version_fixture()
      assert Works.get_version!(version.id) == version
    end

    test "create_version/1 with valid data creates a version" do
      valid_attrs = %{description: "some description", slug: "some slug", title: "some title", urn: "some urn"}

      assert {:ok, %Version{} = version} = Works.create_version(valid_attrs)
      assert version.description == "some description"
      assert version.slug == "some slug"
      assert version.title == "some title"
      assert version.urn == "some urn"
    end

    test "create_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Works.create_version(@invalid_attrs)
    end

    test "update_version/2 with valid data updates the version" do
      version = version_fixture()
      update_attrs = %{description: "some updated description", slug: "some updated slug", title: "some updated title", urn: "some updated urn"}

      assert {:ok, %Version{} = version} = Works.update_version(version, update_attrs)
      assert version.description == "some updated description"
      assert version.slug == "some updated slug"
      assert version.title == "some updated title"
      assert version.urn == "some updated urn"
    end

    test "update_version/2 with invalid data returns error changeset" do
      version = version_fixture()
      assert {:error, %Ecto.Changeset{}} = Works.update_version(version, @invalid_attrs)
      assert version == Works.get_version!(version.id)
    end

    test "delete_version/1 deletes the version" do
      version = version_fixture()
      assert {:ok, %Version{}} = Works.delete_version(version)
      assert_raise Ecto.NoResultsError, fn -> Works.get_version!(version.id) end
    end

    test "change_version/1 returns a version changeset" do
      version = version_fixture()
      assert %Ecto.Changeset{} = Works.change_version(version)
    end
  end

  describe "refs_decls" do
    alias TextServer.Works.RefsDecl

    import TextServer.WorksFixtures

    @invalid_attrs %{description: nil, label: nil, match_pattern: nil, replacement_pattern: nil, slug: nil, structure_index: nil, urn: nil}

    test "list_refs_decls/0 returns all refs_decls" do
      refs_decl = refs_decl_fixture()
      assert Works.list_refs_decls() == [refs_decl]
    end

    test "get_refs_decl!/1 returns the refs_decl with given id" do
      refs_decl = refs_decl_fixture()
      assert Works.get_refs_decl!(refs_decl.id) == refs_decl
    end

    test "create_refs_decl/1 with valid data creates a refs_decl" do
      valid_attrs = %{description: "some description", label: "some label", match_pattern: "some match_pattern", replacement_pattern: "some replacement_pattern", slug: "some slug", structure_index: 42, urn: "some urn"}

      assert {:ok, %RefsDecl{} = refs_decl} = Works.create_refs_decl(valid_attrs)
      assert refs_decl.description == "some description"
      assert refs_decl.label == "some label"
      assert refs_decl.match_pattern == "some match_pattern"
      assert refs_decl.replacement_pattern == "some replacement_pattern"
      assert refs_decl.slug == "some slug"
      assert refs_decl.structure_index == 42
      assert refs_decl.urn == "some urn"
    end

    test "create_refs_decl/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Works.create_refs_decl(@invalid_attrs)
    end

    test "update_refs_decl/2 with valid data updates the refs_decl" do
      refs_decl = refs_decl_fixture()
      update_attrs = %{description: "some updated description", label: "some updated label", match_pattern: "some updated match_pattern", replacement_pattern: "some updated replacement_pattern", slug: "some updated slug", structure_index: 43, urn: "some updated urn"}

      assert {:ok, %RefsDecl{} = refs_decl} = Works.update_refs_decl(refs_decl, update_attrs)
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
      assert {:error, %Ecto.Changeset{}} = Works.update_refs_decl(refs_decl, @invalid_attrs)
      assert refs_decl == Works.get_refs_decl!(refs_decl.id)
    end

    test "delete_refs_decl/1 deletes the refs_decl" do
      refs_decl = refs_decl_fixture()
      assert {:ok, %RefsDecl{}} = Works.delete_refs_decl(refs_decl)
      assert_raise Ecto.NoResultsError, fn -> Works.get_refs_decl!(refs_decl.id) end
    end

    test "change_refs_decl/1 returns a refs_decl changeset" do
      refs_decl = refs_decl_fixture()
      assert %Ecto.Changeset{} = Works.change_refs_decl(refs_decl)
    end
  end
end
