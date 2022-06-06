defmodule TextServer.TextNodesTest do
  use TextServer.DataCase

  alias TextServer.TextNodes

  describe "text_nodes" do
    alias TextServer.TextNodes.TextNode

    import TextServer.TextNodesFixtures

    @invalid_attrs %{index: nil, location: nil, normalized_text: nil, text: nil}

    test "list_text_nodes/0 returns all text_nodes" do
      text_node = text_node_fixture()
      assert TextNodes.list_text_nodes() == [text_node]
    end

    test "get_text_node!/1 returns the text_node with given id" do
      text_node = text_node_fixture()
      assert TextNodes.get_text_node!(text_node.id) == text_node
    end

    test "create_text_node/1 with valid data creates a text_node" do
      valid_attrs = %{index: 42, location: [], normalized_text: "some normalized_text", text: "some text"}

      assert {:ok, %TextNode{} = text_node} = TextNodes.create_text_node(valid_attrs)
      assert text_node.index == 42
      assert text_node.location == []
      assert text_node.normalized_text == "some normalized_text"
      assert text_node.text == "some text"
    end

    test "create_text_node/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TextNodes.create_text_node(@invalid_attrs)
    end

    test "update_text_node/2 with valid data updates the text_node" do
      text_node = text_node_fixture()
      update_attrs = %{index: 43, location: [], normalized_text: "some updated normalized_text", text: "some updated text"}

      assert {:ok, %TextNode{} = text_node} = TextNodes.update_text_node(text_node, update_attrs)
      assert text_node.index == 43
      assert text_node.location == []
      assert text_node.normalized_text == "some updated normalized_text"
      assert text_node.text == "some updated text"
    end

    test "update_text_node/2 with invalid data returns error changeset" do
      text_node = text_node_fixture()
      assert {:error, %Ecto.Changeset{}} = TextNodes.update_text_node(text_node, @invalid_attrs)
      assert text_node == TextNodes.get_text_node!(text_node.id)
    end

    test "delete_text_node/1 deletes the text_node" do
      text_node = text_node_fixture()
      assert {:ok, %TextNode{}} = TextNodes.delete_text_node(text_node)
      assert_raise Ecto.NoResultsError, fn -> TextNodes.get_text_node!(text_node.id) end
    end

    test "change_text_node/1 returns a text_node changeset" do
      text_node = text_node_fixture()
      assert %Ecto.Changeset{} = TextNodes.change_text_node(text_node)
    end
  end
end
