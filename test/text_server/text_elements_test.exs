defmodule TextServer.TextElementsTest do
  use TextServer.DataCase

  alias TextServer.TextElements

  describe "text_elements" do
    alias TextServer.TextElements.TextElement

    import TextServer.TextElementsFixtures

    @invalid_attrs %{attributes: nil, end_urn: nil}

    test "list_text_elements/0 returns all text_elements" do
      text_element = text_element_fixture()
      assert TextElements.list_text_elements() == [text_element]
    end

    test "get_text_element!/1 returns the text_element with given id" do
      text_element = text_element_fixture()
      assert TextElements.get_text_element!(text_element.id) == text_element
    end

    test "create_text_element/1 with valid data creates a text_element" do
      valid_attrs = %{attributes: %{}, end_urn: "some end_urn"}

      assert {:ok, %TextElement{} = text_element} = TextElements.create_text_element(valid_attrs)
      assert text_element.attributes == %{}
      assert text_element.end_urn == "some end_urn"
    end

    test "create_text_element/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TextElements.create_text_element(@invalid_attrs)
    end

    test "update_text_element/2 with valid data updates the text_element" do
      text_element = text_element_fixture()
      update_attrs = %{attributes: %{}, end_urn: "some updated end_urn"}

      assert {:ok, %TextElement{} = text_element} =
               TextElements.update_text_element(text_element, update_attrs)

      assert text_element.attributes == %{}
      assert text_element.end_urn == "some updated end_urn"
    end

    test "update_text_element/2 with invalid data returns error changeset" do
      text_element = text_element_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TextElements.update_text_element(text_element, @invalid_attrs)

      assert text_element == TextElements.get_text_element!(text_element.id)
    end

    test "delete_text_element/1 deletes the text_element" do
      text_element = text_element_fixture()
      assert {:ok, %TextElement{}} = TextElements.delete_text_element(text_element)
      assert_raise Ecto.NoResultsError, fn -> TextElements.get_text_element!(text_element.id) end
    end

    test "change_text_element/1 returns a text_element changeset" do
      text_element = text_element_fixture()
      assert %Ecto.Changeset{} = TextElements.change_text_element(text_element)
    end
  end
end
