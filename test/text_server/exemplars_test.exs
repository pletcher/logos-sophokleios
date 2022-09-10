defmodule TextServer.ExemplarsTest do
  use TextServer.DataCase

  alias TextServer.Exemplars
  alias TextServer.Exemplars.Exemplar
  alias TextServer.TextNodes

  describe "exemplars" do
    import TextServer.ExemplarsFixtures

    @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

    test "list_exemplars/0 returns all exemplars" do
      exemplar = exemplar_fixture()
      assert Exemplars.list_exemplars() == [exemplar]
    end

    test "get_exemplar!/1 returns the exemplar with given id" do
      exemplar = exemplar_fixture()
      assert Exemplars.get_exemplar!(exemplar.id) == exemplar
    end

    test "create_exemplar/1 with valid data creates a exemplar" do
      valid_attrs = %{
        description: "some description",
        slug: "some slug",
        title: "some title",
        urn: "some urn"
      }

      assert {:ok, %Exemplar{} = exemplar} = Exemplars.create_exemplar(valid_attrs)
      assert exemplar.description == "some description"
      assert exemplar.slug == "some slug"
      assert exemplar.title == "some title"
      assert exemplar.urn == "some urn"
    end

    test "create_exemplar/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Exemplars.create_exemplar(@invalid_attrs)
    end

    test "update_exemplar/2 with valid data updates the exemplar" do
      exemplar = exemplar_fixture()

      update_attrs = %{
        description: "some updated description",
        slug: "some updated slug",
        title: "some updated title",
        urn: "some updated urn"
      }

      assert {:ok, %Exemplar{} = exemplar} = Exemplars.update_exemplar(exemplar, update_attrs)
      assert exemplar.description == "some updated description"
      assert exemplar.slug == "some updated slug"
      assert exemplar.title == "some updated title"
      assert exemplar.urn == "some updated urn"
    end

    test "update_exemplar/2 with invalid data returns error changeset" do
      exemplar = exemplar_fixture()
      assert {:error, %Ecto.Changeset{}} = Exemplars.update_exemplar(exemplar, @invalid_attrs)
      assert exemplar == Exemplars.get_exemplar!(exemplar.id)
    end

    test "delete_exemplar/1 deletes the exemplar" do
      exemplar = exemplar_fixture()
      assert {:ok, %Exemplar{}} = Exemplars.delete_exemplar(exemplar)
      assert_raise Ecto.NoResultsError, fn -> Exemplars.get_exemplar!(exemplar.id) end
    end

    test "change_exemplar/1 returns a exemplar changeset" do
      exemplar = exemplar_fixture()
      assert %Ecto.Changeset{} = Exemplars.change_exemplar(exemplar)
    end
  end

  describe "Exemplar DOCX parsing" do
    import TextServer.ExemplarsFixtures

    test "parse_exemplar/1 can parse a docx" do
      exemplar = exemplar_with_docx_fixture()

      assert {:ok, %Exemplar{} = _} = Exemplars.parse_exemplar(exemplar)

      # there should only be one text node created for now
      text_node = TextNodes.get_by(%{exemplar_id: exemplar.id})

      assert String.contains?(text_node.text, "This is a test")
    end
  end
end
