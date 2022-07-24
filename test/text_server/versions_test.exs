defmodule TextServer.VersionsTest do
  use TextServer.DataCase

  alias TextServer.Versions

  describe "versions" do
    alias TextServer.Versions.Version

    import TextServer.VersionsFixtures

    @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

    test "list_versions/0 returns all versions" do
      version = version_fixture()
      assert Versions.list_versions() == [version]
    end

    test "get_version!/1 returns the version with given id" do
      version = version_fixture()
      assert Versions.get_version!(version.id) == version
    end

    test "create_version/1 with valid data creates a version" do
      valid_attrs = %{
        description: "some description",
        slug: "some slug",
        title: "some title",
        urn: "some urn"
      }

      assert {:ok, %Version{} = version} = Versions.create_version(valid_attrs)
      assert version.description == "some description"
      assert version.slug == "some slug"
      assert version.title == "some title"
      assert version.urn == "some urn"
    end

    test "create_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Versions.create_version(@invalid_attrs)
    end

    test "update_version/2 with valid data updates the version" do
      version = version_fixture()

      update_attrs = %{
        description: "some updated description",
        slug: "some updated slug",
        title: "some updated title",
        urn: "some updated urn"
      }

      assert {:ok, %Version{} = version} = Versions.update_version(version, update_attrs)
      assert version.description == "some updated description"
      assert version.slug == "some updated slug"
      assert version.title == "some updated title"
      assert version.urn == "some updated urn"
    end

    test "update_version/2 with invalid data returns error changeset" do
      version = version_fixture()
      assert {:error, %Ecto.Changeset{}} = Versions.update_version(version, @invalid_attrs)
      assert version == Versions.get_version!(version.id)
    end

    test "delete_version/1 deletes the version" do
      version = version_fixture()
      assert {:ok, %Version{}} = Versions.delete_version(version)
      assert_raise Ecto.NoResultsError, fn -> Versions.get_version!(version.id) end
    end

    test "change_version/1 returns a version changeset" do
      version = version_fixture()
      assert %Ecto.Changeset{} = Versions.change_version(version)
    end
  end
end
