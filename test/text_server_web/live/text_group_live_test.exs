defmodule TextServerWeb.TextGroupLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.TextGroupsFixtures

  @create_attrs %{slug: "some slug", title: "some title", urn: "some urn"}
  @update_attrs %{slug: "some updated slug", title: "some updated title", urn: "some updated urn"}
  @invalid_attrs %{slug: nil, title: nil, urn: nil}

  defp create_text_group(_) do
    text_group = text_group_fixture()
    %{text_group: text_group}
  end

  describe "Index" do
    setup [:create_text_group]

    test "lists all text_groups", %{conn: conn, text_group: text_group} do
      {:ok, _index_live, html} = live(conn, Routes.text_group_index_path(conn, :index))

      assert html =~ "Listing Text groups"
      assert html =~ text_group.slug
    end

    test "saves new text_group", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.text_group_index_path(conn, :index))

      assert index_live |> element("a", "New Text group") |> render_click() =~
               "New Text group"

      assert_patch(index_live, Routes.text_group_index_path(conn, :new))

      assert index_live
             |> form("#text_group-form", text_group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#text_group-form", text_group: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.text_group_index_path(conn, :index))

      assert html =~ "Text group created successfully"
      assert html =~ "some slug"
    end

    test "updates text_group in listing", %{conn: conn, text_group: text_group} do
      {:ok, index_live, _html} = live(conn, Routes.text_group_index_path(conn, :index))

      assert index_live |> element("#text_group-#{text_group.id} a", "Edit") |> render_click() =~
               "Edit Text group"

      assert_patch(index_live, Routes.text_group_index_path(conn, :edit, text_group))

      assert index_live
             |> form("#text_group-form", text_group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#text_group-form", text_group: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.text_group_index_path(conn, :index))

      assert html =~ "Text group updated successfully"
      assert html =~ "some updated slug"
    end

    test "deletes text_group in listing", %{conn: conn, text_group: text_group} do
      {:ok, index_live, _html} = live(conn, Routes.text_group_index_path(conn, :index))

      assert index_live |> element("#text_group-#{text_group.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#text_group-#{text_group.id}")
    end
  end

  describe "Show" do
    setup [:create_text_group]

    test "displays text_group", %{conn: conn, text_group: text_group} do
      {:ok, _show_live, html} = live(conn, Routes.text_group_show_path(conn, :show, text_group))

      assert html =~ "Show Text group"
      assert html =~ text_group.slug
    end

    test "updates text_group within modal", %{conn: conn, text_group: text_group} do
      {:ok, show_live, _html} = live(conn, Routes.text_group_show_path(conn, :show, text_group))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Text group"

      assert_patch(show_live, Routes.text_group_show_path(conn, :edit, text_group))

      assert show_live
             |> form("#text_group-form", text_group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#text_group-form", text_group: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.text_group_show_path(conn, :show, text_group))

      assert html =~ "Text group updated successfully"
      assert html =~ "some updated slug"
    end
  end
end
