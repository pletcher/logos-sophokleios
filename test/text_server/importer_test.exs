defmodule TextServer.ImporterTest do
  use TextServer.DataCase

  alias TextServer.Importer

  describe "collections" do
    alias TextServer.Importer.Collection

    import TextServer.ImporterFixtures

    @invalid_attrs %{}

    test "list_collections/0 returns all collections" do
      collection = collection_fixture()
      assert Importer.list_collections() == [collection]
    end

    test "get_collection!/1 returns the collection with given id" do
      collection = collection_fixture()
      assert Importer.get_collection!(collection.id) == collection
    end

    test "create_collection/1 with valid data creates a collection" do
      valid_attrs = %{}

      assert {:ok, %Collection{} = collection} = Importer.create_collection(valid_attrs)
    end

    test "create_collection/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Importer.create_collection(@invalid_attrs)
    end

    test "update_collection/2 with valid data updates the collection" do
      collection = collection_fixture()
      update_attrs = %{}

      assert {:ok, %Collection{} = collection} = Importer.update_collection(collection, update_attrs)
    end

    test "update_collection/2 with invalid data returns error changeset" do
      collection = collection_fixture()
      assert {:error, %Ecto.Changeset{}} = Importer.update_collection(collection, @invalid_attrs)
      assert collection == Importer.get_collection!(collection.id)
    end

    test "delete_collection/1 deletes the collection" do
      collection = collection_fixture()
      assert {:ok, %Collection{}} = Importer.delete_collection(collection)
      assert_raise Ecto.NoResultsError, fn -> Importer.get_collection!(collection.id) end
    end

    test "change_collection/1 returns a collection changeset" do
      collection = collection_fixture()
      assert %Ecto.Changeset{} = Importer.change_collection(collection)
    end
  end

  describe "repositories" do
    alias TextServer.Importer.Repository

    import TextServer.ImporterFixtures

    @invalid_attrs %{}

    test "list_repositories/0 returns all repositories" do
      repository = repository_fixture()
      assert Importer.list_repositories() == [repository]
    end

    test "get_repository!/1 returns the repository with given id" do
      repository = repository_fixture()
      assert Importer.get_repository!(repository.id) == repository
    end

    test "create_repository/1 with valid data creates a repository" do
      valid_attrs = %{}

      assert {:ok, %Repository{} = repository} = Importer.create_repository(valid_attrs)
    end

    test "create_repository/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Importer.create_repository(@invalid_attrs)
    end

    test "update_repository/2 with valid data updates the repository" do
      repository = repository_fixture()
      update_attrs = %{}

      assert {:ok, %Repository{} = repository} = Importer.update_repository(repository, update_attrs)
    end

    test "update_repository/2 with invalid data returns error changeset" do
      repository = repository_fixture()
      assert {:error, %Ecto.Changeset{}} = Importer.update_repository(repository, @invalid_attrs)
      assert repository == Importer.get_repository!(repository.id)
    end

    test "delete_repository/1 deletes the repository" do
      repository = repository_fixture()
      assert {:ok, %Repository{}} = Importer.delete_repository(repository)
      assert_raise Ecto.NoResultsError, fn -> Importer.get_repository!(repository.id) end
    end

    test "change_repository/1 returns a repository changeset" do
      repository = repository_fixture()
      assert %Ecto.Changeset{} = Importer.change_repository(repository)
    end
  end
end
