defmodule TextServerWeb.CollectionLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.CollectionsFixtures

  @create_attrs %{
    repository: "some repository",
    slug: "some slug",
    title: "some title",
    urn: "some urn"
  }
  @update_attrs %{
    repository: "some updated repository",
    slug: "some updated slug",
    title: "some updated title",
    urn: "some updated urn"
  }
  @invalid_attrs %{repository: nil, slug: nil, title: nil, urn: nil}

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

    test "saves new collection", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.collection_index_path(conn, :index))

      assert index_live |> element("a", "New Collection") |> render_click() =~
               "New Collection"

      assert_patch(index_live, Routes.collection_index_path(conn, :new))

      assert index_live
             |> form("#collection-form", collection: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#collection-form", collection: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.collection_index_path(conn, :index))

      assert html =~ "Collection created successfully"
      assert html =~ "some repository"
    end

    test "updates collection in listing", %{conn: conn, collection: collection} do
      {:ok, index_live, _html} = live(conn, Routes.collection_index_path(conn, :index))

      assert index_live |> element("#collection-#{collection.id} a", "Edit") |> render_click() =~
               "Edit Collection"

      assert_patch(index_live, Routes.collection_index_path(conn, :edit, collection))

      assert index_live
             |> form("#collection-form", collection: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#collection-form", collection: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.collection_index_path(conn, :index))

      assert html =~ "Collection updated successfully"
      assert html =~ "some updated repository"
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

    test "updates collection within modal", %{conn: conn, collection: collection} do
      {:ok, show_live, _html} = live(conn, Routes.collection_show_path(conn, :show, collection))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Collection"

      assert_patch(show_live, Routes.collection_show_path(conn, :edit, collection))

      assert show_live
             |> form("#collection-form", collection: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#collection-form", collection: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.collection_show_path(conn, :show, collection))

      assert html =~ "Collection updated successfully"
      assert html =~ "some updated repository"
    end
  end
end
