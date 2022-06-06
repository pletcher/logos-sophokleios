defmodule TextServerWeb.ExemplarLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.ExemplarsFixtures

  @create_attrs %{description: "some description", slug: "some slug", title: "some title", urn: "some urn"}
  @update_attrs %{description: "some updated description", slug: "some updated slug", title: "some updated title", urn: "some updated urn"}
  @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

  defp create_exemplar(_) do
    exemplar = exemplar_fixture()
    %{exemplar: exemplar}
  end

  describe "Index" do
    setup [:create_exemplar]

    test "lists all exemplars", %{conn: conn, exemplar: exemplar} do
      {:ok, _index_live, html} = live(conn, Routes.exemplar_index_path(conn, :index))

      assert html =~ "Listing Exemplars"
      assert html =~ exemplar.description
    end

    test "saves new exemplar", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.exemplar_index_path(conn, :index))

      assert index_live |> element("a", "New Exemplar") |> render_click() =~
               "New Exemplar"

      assert_patch(index_live, Routes.exemplar_index_path(conn, :new))

      assert index_live
             |> form("#exemplar-form", exemplar: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#exemplar-form", exemplar: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.exemplar_index_path(conn, :index))

      assert html =~ "Exemplar created successfully"
      assert html =~ "some description"
    end

    test "updates exemplar in listing", %{conn: conn, exemplar: exemplar} do
      {:ok, index_live, _html} = live(conn, Routes.exemplar_index_path(conn, :index))

      assert index_live |> element("#exemplar-#{exemplar.id} a", "Edit") |> render_click() =~
               "Edit Exemplar"

      assert_patch(index_live, Routes.exemplar_index_path(conn, :edit, exemplar))

      assert index_live
             |> form("#exemplar-form", exemplar: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#exemplar-form", exemplar: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.exemplar_index_path(conn, :index))

      assert html =~ "Exemplar updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes exemplar in listing", %{conn: conn, exemplar: exemplar} do
      {:ok, index_live, _html} = live(conn, Routes.exemplar_index_path(conn, :index))

      assert index_live |> element("#exemplar-#{exemplar.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#exemplar-#{exemplar.id}")
    end
  end

  describe "Show" do
    setup [:create_exemplar]

    test "displays exemplar", %{conn: conn, exemplar: exemplar} do
      {:ok, _show_live, html} = live(conn, Routes.exemplar_show_path(conn, :show, exemplar))

      assert html =~ "Show Exemplar"
      assert html =~ exemplar.description
    end

    test "updates exemplar within modal", %{conn: conn, exemplar: exemplar} do
      {:ok, show_live, _html} = live(conn, Routes.exemplar_show_path(conn, :show, exemplar))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Exemplar"

      assert_patch(show_live, Routes.exemplar_show_path(conn, :edit, exemplar))

      assert show_live
             |> form("#exemplar-form", exemplar: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#exemplar-form", exemplar: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.exemplar_show_path(conn, :show, exemplar))

      assert html =~ "Exemplar updated successfully"
      assert html =~ "some updated description"
    end
  end
end
