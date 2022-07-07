defmodule TextServer.IngestionTest do
  use TextServer.DataCase

  alias TextServer.Ingestion

  describe "ingestion_items" do
    alias TextServer.Ingestion.Item

    import TextServer.IngestionFixtures

    @invalid_attrs %{path: nil}

    test "list_ingestion_items/0 returns all ingestion_items" do
      item = item_fixture()
      assert Ingestion.list_ingestion_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Ingestion.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{path: "some path"}

      assert {:ok, %Item{} = item} = Ingestion.create_item(valid_attrs)
      assert item.path == "some path"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ingestion.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{path: "some updated path"}

      assert {:ok, %Item{} = item} = Ingestion.update_item(item, update_attrs)
      assert item.path == "some updated path"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Ingestion.update_item(item, @invalid_attrs)
      assert item == Ingestion.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Ingestion.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Ingestion.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Ingestion.change_item(item)
    end
  end
end
