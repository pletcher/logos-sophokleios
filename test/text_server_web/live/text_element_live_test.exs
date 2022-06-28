defmodule TextServerWeb.TextElementLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.TextElementsFixtures

  @create_attrs %{attributes: %{}, end_urn: "some end_urn"}
  @update_attrs %{attributes: %{}, end_urn: "some updated end_urn"}
  @invalid_attrs %{attributes: nil, end_urn: nil}

  defp create_text_element(_) do
    text_element = text_element_fixture()
    %{text_element: text_element}
  end

  describe "Index" do
    setup [:create_text_element]

    test "lists all text_elements", %{conn: conn, text_element: text_element} do
      {:ok, _index_live, html} = live(conn, Routes.text_element_index_path(conn, :index))

      assert html =~ "Listing Text elements"
      assert html =~ text_element.end_urn
    end

    test "saves new text_element", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.text_element_index_path(conn, :index))

      assert index_live |> element("a", "New Text element") |> render_click() =~
               "New Text element"

      assert_patch(index_live, Routes.text_element_index_path(conn, :new))

      assert index_live
             |> form("#text_element-form", text_element: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#text_element-form", text_element: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.text_element_index_path(conn, :index))

      assert html =~ "Text element created successfully"
      assert html =~ "some end_urn"
    end

    test "updates text_element in listing", %{conn: conn, text_element: text_element} do
      {:ok, index_live, _html} = live(conn, Routes.text_element_index_path(conn, :index))

      assert index_live |> element("#text_element-#{text_element.id} a", "Edit") |> render_click() =~
               "Edit Text element"

      assert_patch(index_live, Routes.text_element_index_path(conn, :edit, text_element))

      assert index_live
             |> form("#text_element-form", text_element: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#text_element-form", text_element: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.text_element_index_path(conn, :index))

      assert html =~ "Text element updated successfully"
      assert html =~ "some updated end_urn"
    end

    test "deletes text_element in listing", %{conn: conn, text_element: text_element} do
      {:ok, index_live, _html} = live(conn, Routes.text_element_index_path(conn, :index))

      assert index_live |> element("#text_element-#{text_element.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#text_element-#{text_element.id}")
    end
  end

  describe "Show" do
    setup [:create_text_element]

    test "displays text_element", %{conn: conn, text_element: text_element} do
      {:ok, _show_live, html} = live(conn, Routes.text_element_show_path(conn, :show, text_element))

      assert html =~ "Show Text element"
      assert html =~ text_element.end_urn
    end

    test "updates text_element within modal", %{conn: conn, text_element: text_element} do
      {:ok, show_live, _html} = live(conn, Routes.text_element_show_path(conn, :show, text_element))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Text element"

      assert_patch(show_live, Routes.text_element_show_path(conn, :edit, text_element))

      assert show_live
             |> form("#text_element-form", text_element: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#text_element-form", text_element: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.text_element_show_path(conn, :show, text_element))

      assert html =~ "Text element updated successfully"
      assert html =~ "some updated end_urn"
    end
  end
end
