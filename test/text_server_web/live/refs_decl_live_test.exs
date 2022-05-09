defmodule TextServerWeb.RefsDeclLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.TextsFixtures

  @create_attrs %{description: "some description", label: "some label", match_pattern: "some match_pattern", replacement_pattern: "some replacement_pattern", slug: "some slug", structure_index: 42, urn: "some urn"}
  @update_attrs %{description: "some updated description", label: "some updated label", match_pattern: "some updated match_pattern", replacement_pattern: "some updated replacement_pattern", slug: "some updated slug", structure_index: 43, urn: "some updated urn"}
  @invalid_attrs %{description: nil, label: nil, match_pattern: nil, replacement_pattern: nil, slug: nil, structure_index: nil, urn: nil}

  defp create_refs_decl(_) do
    refs_decl = refs_decl_fixture()
    %{refs_decl: refs_decl}
  end

  describe "Index" do
    setup [:create_refs_decl]

    test "lists all refs_decls", %{conn: conn, refs_decl: refs_decl} do
      {:ok, _index_live, html} = live(conn, Routes.refs_decl_index_path(conn, :index))

      assert html =~ "Listing Refs decls"
      assert html =~ refs_decl.description
    end

    test "saves new refs_decl", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.refs_decl_index_path(conn, :index))

      assert index_live |> element("a", "New Refs decl") |> render_click() =~
               "New Refs decl"

      assert_patch(index_live, Routes.refs_decl_index_path(conn, :new))

      assert index_live
             |> form("#refs_decl-form", refs_decl: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#refs_decl-form", refs_decl: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.refs_decl_index_path(conn, :index))

      assert html =~ "Refs decl created successfully"
      assert html =~ "some description"
    end

    test "updates refs_decl in listing", %{conn: conn, refs_decl: refs_decl} do
      {:ok, index_live, _html} = live(conn, Routes.refs_decl_index_path(conn, :index))

      assert index_live |> element("#refs_decl-#{refs_decl.id} a", "Edit") |> render_click() =~
               "Edit Refs decl"

      assert_patch(index_live, Routes.refs_decl_index_path(conn, :edit, refs_decl))

      assert index_live
             |> form("#refs_decl-form", refs_decl: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#refs_decl-form", refs_decl: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.refs_decl_index_path(conn, :index))

      assert html =~ "Refs decl updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes refs_decl in listing", %{conn: conn, refs_decl: refs_decl} do
      {:ok, index_live, _html} = live(conn, Routes.refs_decl_index_path(conn, :index))

      assert index_live |> element("#refs_decl-#{refs_decl.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#refs_decl-#{refs_decl.id}")
    end
  end

  describe "Show" do
    setup [:create_refs_decl]

    test "displays refs_decl", %{conn: conn, refs_decl: refs_decl} do
      {:ok, _show_live, html} = live(conn, Routes.refs_decl_show_path(conn, :show, refs_decl))

      assert html =~ "Show Refs decl"
      assert html =~ refs_decl.description
    end

    test "updates refs_decl within modal", %{conn: conn, refs_decl: refs_decl} do
      {:ok, show_live, _html} = live(conn, Routes.refs_decl_show_path(conn, :show, refs_decl))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Refs decl"

      assert_patch(show_live, Routes.refs_decl_show_path(conn, :edit, refs_decl))

      assert show_live
             |> form("#refs_decl-form", refs_decl: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#refs_decl-form", refs_decl: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.refs_decl_show_path(conn, :show, refs_decl))

      assert html =~ "Refs decl updated successfully"
      assert html =~ "some updated description"
    end
  end
end
