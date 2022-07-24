defmodule TextServer.WorksTest do
  use TextServer.DataCase

  alias TextServer.Works

  describe "works" do
    alias TextServer.Works.Work

    import TextServer.WorksFixtures

    @invalid_attrs %{
      description: nil,
      english_title: nil,
      filemd5hash: nil,
      filename: nil,
      form: nil,
      full_urn: nil,
      label: nil,
      original_title: nil,
      slug: nil,
      structure: nil,
      urn: nil,
      work_type: nil
    }

    test "list_works/0 returns all works" do
      work = work_fixture()
      assert Works.list_works() == [work]
    end

    test "get_work!/1 returns the work with given id" do
      work = work_fixture()
      assert Works.get_work!(work.id) == work
    end

    test "create_work/1 with valid data creates a work" do
      valid_attrs = %{
        description: "some description",
        english_title: "some english_title",
        filemd5hash: "some filemd5hash",
        filename: "some filename",
        form: "some form",
        full_urn: "some full_urn",
        label: "some label",
        original_title: "some original_title",
        slug: "some slug",
        structure: "some structure",
        urn: "some urn",
        work_type: :edition
      }

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

      update_attrs = %{
        description: "some updated description",
        english_title: "some updated english_title",
        filemd5hash: "some updated filemd5hash",
        filename: "some updated filename",
        form: "some updated form",
        full_urn: "some updated full_urn",
        label: "some updated label",
        original_title: "some updated original_title",
        slug: "some updated slug",
        structure: "some updated structure",
        urn: "some updated urn",
        work_type: :translation
      }

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
end
