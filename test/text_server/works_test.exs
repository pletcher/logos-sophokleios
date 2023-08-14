defmodule TextServer.WorksTest do
  use TextServer.DataCase

  alias TextServer.Works

  describe "works" do
    alias TextServer.Works.Work

    import TextServer.TextGroupsFixtures
    import TextServer.WorksFixtures

    @invalid_attrs %{
      description: nil,
      english_title: nil,
      original_title: nil,
      urn: nil
    }

    test "search_works/1 returns a paginated list of works matching the query" do
      work_1 = work_fixture(%{english_title: "Title", description: "bbb"})
      work_2 = work_fixture(%{english_title: "Another title", description: "ddd"})

      search_results = Works.search_works("Anoth").entries

      assert List.first(search_results).id == work_2.id

      search_results = Works.search_works("title").entries

      assert Enum.find(search_results, fn r -> r.id == work_1.id end).id == work_1.id
      assert Enum.find(search_results, fn r -> r.id == work_2.id end).id == work_2.id
    end

    test "get_work!/1 returns the work with given id" do
      work = work_fixture()
      assert Works.get_work!(work.id).id == work.id
    end

    test "create_work/1 with valid data creates a work" do
      valid_attrs = %{
        description: "some description",
        english_title: "some english_title",
        original_title: "some original_title",
        text_group_id: text_group_fixture().id,
        urn: "urn:cts:namespace:text_group.work",
      }

      assert {:ok, %Work{} = work} = Works.create_work(valid_attrs)
      assert work.description == "some description"
      assert work.english_title == "some english_title"
      assert work.original_title == "some original_title"
      assert work.urn == CTS.URN.parse("urn:cts:namespace:text_group.work")
    end

    test "create_work/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Works.create_work(@invalid_attrs)
    end

    test "update_work/2 with valid data updates the work" do
      work = work_fixture()

      update_attrs = %{
        description: "some updated description",
        english_title: "some updated english_title",
        original_title: "some updated original_title",
        text_group_id: text_group_fixture().id,
        urn: "urn:cts:ns:text_group.updated_work",
      }

      assert {:ok, %Work{} = work} = Works.update_work(work, update_attrs)
      assert work.description == "some updated description"
      assert work.english_title == "some updated english_title"
      assert work.original_title == "some updated original_title"
      assert work.urn == CTS.URN.parse("urn:cts:ns:text_group.updated_work")
    end

    test "update_work/2 with invalid data returns error changeset" do
      work = work_fixture()
      assert {:error, %Ecto.Changeset{}} = Works.update_work(work, @invalid_attrs)
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
