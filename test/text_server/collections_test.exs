defmodule TextServer.CollectionsTest do
  use TextServer.DataCase

  alias TextServer.Collections

  describe "collections" do
    alias TextServer.Collections.Collection

    import TextServer.CollectionsFixtures

    @invalid_attrs %{repository: nil, slug: nil, title: nil, urn: nil}

    test "list_collections/0 returns all collections" do
      collection = collection_fixture()
      assert Collections.list_collections() == [collection]
    end

    test "get_collection!/1 returns the collection with given id" do
      collection = collection_fixture()
      assert Collections.get_collection!(collection.id) == collection
    end

    test "create_collection/1 with valid data creates a collection" do
      valid_attrs = %{
        repository: "some repository",
        slug: "some slug",
        title: "some title",
        urn: "some urn"
      }

      assert {:ok, %Collection{} = collection} = Collections.create_collection(valid_attrs)
      assert collection.repository == "some repository"
      assert collection.slug == "some slug"
      assert collection.title == "some title"
      assert collection.urn == "some urn"
    end

    test "create_collection/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Collections.create_collection(@invalid_attrs)
    end

    test "update_collection/2 with valid data updates the collection" do
      collection = collection_fixture()

      update_attrs = %{
        repository: "some updated repository",
        slug: "some updated slug",
        title: "some updated title",
        urn: "some updated urn"
      }

      assert {:ok, %Collection{} = collection} =
               Collections.update_collection(collection, update_attrs)

      assert collection.repository == "some updated repository"
      assert collection.slug == "some updated slug"
      assert collection.title == "some updated title"
      assert collection.urn == "some updated urn"
    end

    test "update_collection/2 with invalid data returns error changeset" do
      collection = collection_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Collections.update_collection(collection, @invalid_attrs)

      assert collection == Collections.get_collection!(collection.id)
    end

    test "delete_collection/1 deletes the collection" do
      collection = collection_fixture()
      assert {:ok, %Collection{}} = Collections.delete_collection(collection)
      assert_raise Ecto.NoResultsError, fn -> Collections.get_collection!(collection.id) end
    end

    test "change_collection/1 returns a collection changeset" do
      collection = collection_fixture()
      assert %Ecto.Changeset{} = Collections.change_collection(collection)
    end
  end
end
