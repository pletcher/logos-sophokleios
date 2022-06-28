defmodule TextServerWeb.ElementTypeLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.ElementTypesFixtures

  @create_attrs %{description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  defp create_element_type(_) do
    element_type = element_type_fixture()
    %{element_type: element_type}
  end

  describe "Index" do
    setup [:create_element_type]

    test "lists all element_types", %{conn: conn, element_type: element_type} do
      {:ok, _index_live, html} = live(conn, Routes.element_type_index_path(conn, :index))

      assert html =~ "Listing Element types"
      assert html =~ element_type.description
    end

    test "saves new element_type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.element_type_index_path(conn, :index))

      assert index_live |> element("a", "New Element type") |> render_click() =~
               "New Element type"

      assert_patch(index_live, Routes.element_type_index_path(conn, :new))

      assert index_live
             |> form("#element_type-form", element_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#element_type-form", element_type: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.element_type_index_path(conn, :index))

      assert html =~ "Element type created successfully"
      assert html =~ "some description"
    end

    test "updates element_type in listing", %{conn: conn, element_type: element_type} do
      {:ok, index_live, _html} = live(conn, Routes.element_type_index_path(conn, :index))

      assert index_live |> element("#element_type-#{element_type.id} a", "Edit") |> render_click() =~
               "Edit Element type"

      assert_patch(index_live, Routes.element_type_index_path(conn, :edit, element_type))

      assert index_live
             |> form("#element_type-form", element_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#element_type-form", element_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.element_type_index_path(conn, :index))

      assert html =~ "Element type updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes element_type in listing", %{conn: conn, element_type: element_type} do
      {:ok, index_live, _html} = live(conn, Routes.element_type_index_path(conn, :index))

      assert index_live |> element("#element_type-#{element_type.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#element_type-#{element_type.id}")
    end
  end

  describe "Show" do
    setup [:create_element_type]

    test "displays element_type", %{conn: conn, element_type: element_type} do
      {:ok, _show_live, html} = live(conn, Routes.element_type_show_path(conn, :show, element_type))

      assert html =~ "Show Element type"
      assert html =~ element_type.description
    end

    test "updates element_type within modal", %{conn: conn, element_type: element_type} do
      {:ok, show_live, _html} = live(conn, Routes.element_type_show_path(conn, :show, element_type))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Element type"

      assert_patch(show_live, Routes.element_type_show_path(conn, :edit, element_type))

      assert show_live
             |> form("#element_type-form", element_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#element_type-form", element_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.element_type_show_path(conn, :show, element_type))

      assert html =~ "Element type updated successfully"
      assert html =~ "some updated description"
    end
  end
end
