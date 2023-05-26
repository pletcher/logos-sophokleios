defmodule TextServer.XmlTest do
  use TextServer.DataCase

  alias TextServer.Xml

  describe "xml_versions" do
    alias TextServer.Xml.Version

    import TextServer.XmlFixtures
    import TextServer.WorksFixtures

    @invalid_attrs %{
      version_type: nil,
      urn: nil,
      xml_document: nil
    }

    test "list_xml_versions/0 returns all xml_versions" do
      version = version_fixture()
      assert Xml.list_xml_versions() == [version]
    end

    test "get_version!/1 returns the version with given id" do
      version = version_fixture()
      assert Xml.get_version!(version.id) == version
    end

    test "create_version/1 with valid data creates a version" do
      valid_attrs = %{
        version_type: :edition,
        urn: "urn:cts:latinLit:stoa001.stoa002.perseus-lat2",
        work_id: work_fixture().id,
        xml_document: "<ul><li>foo</li></ul>"
      }

      assert {:ok, %Version{} = version} = Xml.create_version(valid_attrs)
      assert version.xml_document == "<ul><li>foo</li></ul>"
    end

    test "create_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Xml.create_version(@invalid_attrs)
    end

    test "update_version/2 with valid data updates the version" do
      version = version_fixture()
      update_attrs = %{xml_document: "<div><p>hey</p></div>"}

      assert {:ok, %Version{} = version} = Xml.update_version(version, update_attrs)
      assert version.xml_document == "<div><p>hey</p></div>"
    end

    test "update_version/2 with invalid data returns error changeset" do
      version = version_fixture()
      assert {:error, %Ecto.Changeset{}} = Xml.update_version(version, @invalid_attrs)
      assert version == Xml.get_version!(version.id)
    end

    test "delete_version/1 deletes the version" do
      version = version_fixture()
      assert {:ok, %Version{}} = Xml.delete_version(version)
      assert_raise Ecto.NoResultsError, fn -> Xml.get_version!(version.id) end
    end

    test "change_version/1 returns a version changeset" do
      version = version_fixture()
      assert %Ecto.Changeset{} = Xml.change_version(version)
    end
  end
end
