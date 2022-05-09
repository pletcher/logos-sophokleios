defmodule TextServerWeb.TranslationLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.TextsFixtures

  @create_attrs %{description: "some description", slug: "some slug", title: "some title", urn: "some urn"}
  @update_attrs %{description: "some updated description", slug: "some updated slug", title: "some updated title", urn: "some updated urn"}
  @invalid_attrs %{description: nil, slug: nil, title: nil, urn: nil}

  defp create_translation(_) do
    translation = translation_fixture()
    %{translation: translation}
  end

  describe "Index" do
    setup [:create_translation]

    test "lists all translations", %{conn: conn, translation: translation} do
      {:ok, _index_live, html} = live(conn, Routes.translation_index_path(conn, :index))

      assert html =~ "Listing Translations"
      assert html =~ translation.description
    end

    test "saves new translation", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.translation_index_path(conn, :index))

      assert index_live |> element("a", "New Translation") |> render_click() =~
               "New Translation"

      assert_patch(index_live, Routes.translation_index_path(conn, :new))

      assert index_live
             |> form("#translation-form", translation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#translation-form", translation: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.translation_index_path(conn, :index))

      assert html =~ "Translation created successfully"
      assert html =~ "some description"
    end

    test "updates translation in listing", %{conn: conn, translation: translation} do
      {:ok, index_live, _html} = live(conn, Routes.translation_index_path(conn, :index))

      assert index_live |> element("#translation-#{translation.id} a", "Edit") |> render_click() =~
               "Edit Translation"

      assert_patch(index_live, Routes.translation_index_path(conn, :edit, translation))

      assert index_live
             |> form("#translation-form", translation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#translation-form", translation: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.translation_index_path(conn, :index))

      assert html =~ "Translation updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes translation in listing", %{conn: conn, translation: translation} do
      {:ok, index_live, _html} = live(conn, Routes.translation_index_path(conn, :index))

      assert index_live |> element("#translation-#{translation.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#translation-#{translation.id}")
    end
  end

  describe "Show" do
    setup [:create_translation]

    test "displays translation", %{conn: conn, translation: translation} do
      {:ok, _show_live, html} = live(conn, Routes.translation_show_path(conn, :show, translation))

      assert html =~ "Show Translation"
      assert html =~ translation.description
    end

    test "updates translation within modal", %{conn: conn, translation: translation} do
      {:ok, show_live, _html} = live(conn, Routes.translation_show_path(conn, :show, translation))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Translation"

      assert_patch(show_live, Routes.translation_show_path(conn, :edit, translation))

      assert show_live
             |> form("#translation-form", translation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#translation-form", translation: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.translation_show_path(conn, :show, translation))

      assert html =~ "Translation updated successfully"
      assert html =~ "some updated description"
    end
  end
end
