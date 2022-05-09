defmodule TextServerWeb.VersionLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.TextsFixtures

  @create_attrs %{description: "some description", slug: "some slug", title: "some title", urn: "some urn"}
  @update_attrs %{description: "some updated description", slug: "some updated slug", title: "some updated title", urn: "some updated urn"}
  @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

  defp create_version(_) do
    version = version_fixture()
    %{version: version}
  end

  describe "Index" do
    setup [:create_version]

    test "lists all versions", %{conn: conn, version: version} do
      {:ok, _index_live, html} = live(conn, Routes.version_index_path(conn, :index))

      assert html =~ "Listing Versions"
      assert html =~ version.description
    end

    test "saves new version", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.version_index_path(conn, :index))

      assert index_live |> element("a", "New Version") |> render_click() =~
               "New Version"

      assert_patch(index_live, Routes.version_index_path(conn, :new))

      assert index_live
             |> form("#version-form", version: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#version-form", version: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.version_index_path(conn, :index))

      assert html =~ "Version created successfully"
      assert html =~ "some description"
    end

    test "updates version in listing", %{conn: conn, version: version} do
      {:ok, index_live, _html} = live(conn, Routes.version_index_path(conn, :index))

      assert index_live |> element("#version-#{version.id} a", "Edit") |> render_click() =~
               "Edit Version"

      assert_patch(index_live, Routes.version_index_path(conn, :edit, version))

      assert index_live
             |> form("#version-form", version: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#version-form", version: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.version_index_path(conn, :index))

      assert html =~ "Version updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes version in listing", %{conn: conn, version: version} do
      {:ok, index_live, _html} = live(conn, Routes.version_index_path(conn, :index))

      assert index_live |> element("#version-#{version.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#version-#{version.id}")
    end
  end

  describe "Show" do
    setup [:create_version]

    test "displays version", %{conn: conn, version: version} do
      {:ok, _show_live, html} = live(conn, Routes.version_show_path(conn, :show, version))

      assert html =~ "Show Version"
      assert html =~ version.description
    end

    test "updates version within modal", %{conn: conn, version: version} do
      {:ok, show_live, _html} = live(conn, Routes.version_show_path(conn, :show, version))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Version"

      assert_patch(show_live, Routes.version_show_path(conn, :edit, version))

      assert show_live
             |> form("#version-form", version: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#version-form", version: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.version_show_path(conn, :show, version))

      assert html =~ "Version updated successfully"
      assert html =~ "some updated description"
    end
  end
end
