defmodule TextServer.TextGroupsTest do
  use TextServer.DataCase

  alias TextServer.TextGroups

  describe "text_groups" do
    alias TextServer.TextGroups.TextGroup

    import TextServer.TextGroupsFixtures

    @invalid_attrs %{slug: nil, title: nil, urn: nil}

    test "list_text_groups/0 returns all text_groups" do
      text_group = text_group_fixture()
      assert TextGroups.list_text_groups() == [text_group]
    end

    test "get_text_group!/1 returns the text_group with given id" do
      text_group = text_group_fixture()
      assert TextGroups.get_text_group!(text_group.id) == text_group
    end

    test "create_text_group/1 with valid data creates a text_group" do
      valid_attrs = %{slug: "some slug", title: "some title", urn: "some urn"}

      assert {:ok, %TextGroup{} = text_group} = TextGroups.create_text_group(valid_attrs)
      assert text_group.slug == "some slug"
      assert text_group.title == "some title"
      assert text_group.urn == "some urn"
    end

    test "create_text_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TextGroups.create_text_group(@invalid_attrs)
    end

    test "update_text_group/2 with valid data updates the text_group" do
      text_group = text_group_fixture()

      update_attrs = %{
        slug: "some updated slug",
        title: "some updated title",
        urn: "some updated urn"
      }

      assert {:ok, %TextGroup{} = text_group} =
               TextGroups.update_text_group(text_group, update_attrs)

      assert text_group.slug == "some updated slug"
      assert text_group.title == "some updated title"
      assert text_group.urn == "some updated urn"
    end

    test "update_text_group/2 with invalid data returns error changeset" do
      text_group = text_group_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TextGroups.update_text_group(text_group, @invalid_attrs)

      assert text_group == TextGroups.get_text_group!(text_group.id)
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
