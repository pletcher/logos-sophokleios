defmodule TextServer.TextGroupsTest do
  use TextServer.DataCase

  alias TextServer.TextGroups
  alias TextServer.TextGroups.TextGroup

  import TextServer.TextGroupsFixtures

  @valid_attrs %{
    title: "some title",
    urn: "urn:cts:some:urn"
  }
  @invalid_attrs %{title: nil, urn: nil}

  describe "text_groups" do
    test "list_text_groups/0 returns all text_groups" do
      text_group = text_group_fixture()
      assert List.first(TextGroups.list_text_groups()).id == text_group.id
    end

    test "get_text_group!/1 returns the text_group with given id" do
      text_group = text_group_fixture()
      assert TextGroups.get_text_group!(text_group.id).title == text_group.title
    end

    test "create_text_group/1 with valid data creates a text_group" do
      collection = TextServer.CollectionsFixtures.collection_fixture()

      assert {:ok, %TextGroup{} = text_group} =
               TextGroups.create_text_group(
                 @valid_attrs
                 |> Map.put(:collection_id, collection.id)
               )

      assert text_group.title == "some title"
      assert text_group.urn == "urn:cts:some:urn"
    end

    test "create_text_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TextGroups.create_text_group(@invalid_attrs)
    end

    test "update_text_group/2 with valid data updates the text_group" do
      text_group = text_group_fixture()

      update_attrs = %{
        title: "some updated title",
        urn: "urn:cts:some:updated_urn"
      }

      assert {:ok, %TextGroup{} = text_group} =
               TextGroups.update_text_group(text_group, update_attrs)

      assert text_group.title == "some updated title"
      assert text_group.urn == "urn:cts:some:updated_urn"
    end

    test "update_text_group/2 with invalid data returns error changeset" do
      text_group = text_group_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TextGroups.update_text_group(text_group, @invalid_attrs)
    end

    test "delete_text_group/1 deletes the text_group" do
      text_group = text_group_fixture()
      assert {:ok, %TextGroup{}} = TextGroups.delete_text_group(text_group)
      assert_raise Ecto.NoResultsError, fn -> TextGroups.get_text_group!(text_group.id) end
    end

    test "change_text_group/1 returns a text_group changeset" do
      text_group = text_group_fixture()
      assert %Ecto.Changeset{} = TextGroups.change_text_group(text_group)
    end
  end
end
