defmodule TextServerWeb.CollectionLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.CollectionsFixtures

  defp create_collection(_) do
    collection = collection_fixture()
    %{collection: collection}
  end

  describe "Index" do
    setup [:create_collection]

    test "lists all collections", %{conn: conn, collection: collection} do
      {:ok, _index_live, html} = live(conn, Routes.collection_index_path(conn, :index))

      assert html =~ "Listing Collections"
      assert html =~ collection.repository
    end

   test "deletes collection in listing", %{conn: conn, collection: collection} do
      {:ok, index_live, _html} = live(conn, Routes.collection_index_path(conn, :index))

      assert index_live |> element("#collection-#{collection.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#collection-#{collection.id}")
    end
  end

  describe "Show" do
    setup [:create_collection]

    test "displays collection", %{conn: conn, collection: collection} do
      {:ok, _show_live, html} = live(conn, Routes.collection_show_path(conn, :show, collection))

      assert html =~ "Show Collection"
      assert html =~ collection.repository
    end
  end
end
