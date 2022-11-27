defmodule TextServer.CollectionsTest do
  use TextServer.DataCase

  alias TextServer.Collections
  alias TextServer.Collections.Collection

  import TextServer.CollectionsFixtures

  @valid_attrs %{
    repository: "https://git.repository.test/collection",
    title: "some title",
    urn: "urn:cts:some:urn"
  }
  @invalid_attrs %{repository: nil, title: nil, urn: nil}

  describe "collections" do
    test "list_collections/0 returns all collections" do
      collection = collection_fixture()
      assert Collections.list_collections() == [collection]
    end

    test "get_collection!/1 returns the collection with given id" do
      collection = collection_fixture()
      assert Collections.get_collection!(collection.id) == collection
    end

    test "create_collection/1 with valid data creates a collection" do
      assert {:ok, %Collection{} = collection} = Collections.create_collection(@valid_attrs)
      assert collection.repository == "https://git.repository.test/collection"
      assert collection.title == "some title"
      assert collection.urn == "urn:cts:some:urn"
    end

    test "create_collection/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Collections.create_collection(@invalid_attrs)
    end

    test "update_collection/2 with valid data updates the collection" do
      collection = collection_fixture()

      update_attrs = %{
        repository: "https://git.repository.test/some_updated_repository",
        title: "some updated title",
        urn: "urn:cts:some:updated_urn"
      }

      assert {:ok, %Collection{} = collection} =
               Collections.update_collection(collection, update_attrs)

      assert collection.repository == "https://git.repository.test/some_updated_repository"
      assert collection.title == "some updated title"
      assert collection.urn == "urn:cts:some:updated_urn"
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
