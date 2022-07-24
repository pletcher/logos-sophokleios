defmodule TextServer.ElementTypesTest do
  use TextServer.DataCase

  alias TextServer.ElementTypes

  describe "element_types" do
    alias TextServer.ElementTypes.ElementType

    import TextServer.ElementTypesFixtures

    @invalid_attrs %{description: nil, name: nil}

    test "list_element_types/0 returns all element_types" do
      element_type = element_type_fixture()
      assert ElementTypes.list_element_types() == [element_type]
    end

    test "get_element_type!/1 returns the element_type with given id" do
      element_type = element_type_fixture()
      assert ElementTypes.get_element_type!(element_type.id) == element_type
    end

    test "create_element_type/1 with valid data creates a element_type" do
      valid_attrs = %{description: "some description", name: "some name"}

      assert {:ok, %ElementType{} = element_type} = ElementTypes.create_element_type(valid_attrs)
      assert element_type.description == "some description"
      assert element_type.name == "some name"
    end

    test "create_element_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ElementTypes.create_element_type(@invalid_attrs)
    end

    test "update_element_type/2 with valid data updates the element_type" do
      element_type = element_type_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name"}

      assert {:ok, %ElementType{} = element_type} =
               ElementTypes.update_element_type(element_type, update_attrs)

      assert element_type.description == "some updated description"
      assert element_type.name == "some updated name"
    end

    test "update_element_type/2 with invalid data returns error changeset" do
      element_type = element_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ElementTypes.update_element_type(element_type, @invalid_attrs)

      assert element_type == ElementTypes.get_element_type!(element_type.id)
    end

    test "delete_element_type/1 deletes the element_type" do
      element_type = element_type_fixture()
      assert {:ok, %ElementType{}} = ElementTypes.delete_element_type(element_type)
      assert_raise Ecto.NoResultsError, fn -> ElementTypes.get_element_type!(element_type.id) end
    end

    test "change_element_type/1 returns a element_type changeset" do
      element_type = element_type_fixture()
      assert %Ecto.Changeset{} = ElementTypes.change_element_type(element_type)
    end
  end
end
