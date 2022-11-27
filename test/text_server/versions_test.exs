defmodule TextServer.VersionsTest do
  use TextServer.DataCase

  alias TextServer.Versions
  alias TextServer.Versions.Version

  import TextServer.VersionsFixtures

  @valid_attrs %{
    description: "some description",
    label: "some label",
    urn: "urn:cts:some:urn",
    version_type: "commentary"
  }
  @invalid_attrs %{description: nil, label: nil, urn: nil, version_type: nil}

  describe "versions" do
    test "list_versions/0 returns all versions" do
      version = version_fixture()
      assert Versions.list_versions().entries == [version]
    end

    test "get_version!/1 returns the version with given id" do
      version = version_fixture()
      assert Versions.get_version!(version.id) == version
    end

    test "create_version/1 with valid data creates a version" do
      work = TextServer.WorksFixtures.work_fixture()
      assert {:ok, %Version{} = version} = Versions.create_version(Map.put(@valid_attrs, :work_id, work.id))
      assert version.description == "some description"
      assert version.label == "some label"
      assert version.urn == "urn:cts:some:urn"
      assert version.version_type == :commentary
    end

    test "create_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Versions.create_version(@invalid_attrs)
    end

    test "update_version/2 with valid data updates the version" do
      version = version_fixture()

      update_attrs = %{
        description: "some updated description",
        label: "some updated label",
        urn: "urn:cts:some:updated_urn"
      }

      assert {:ok, %Version{} = version} = Versions.update_version(version, update_attrs)
      assert version.description == "some updated description"
      assert version.label == "some updated label"
      assert version.urn == "urn:cts:some:updated_urn"
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
