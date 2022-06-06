defmodule TextServerWeb.LanguageLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.LanguagesFixtures

  @create_attrs %{slug: "some slug", title: "some title"}
  @update_attrs %{slug: "some updated slug", title: "some updated title"}
  @invalid_attrs %{slug: nil, title: nil}

  defp create_language(_) do
    language = language_fixture()
    %{language: language}
  end

  describe "Index" do
    setup [:create_language]

    test "lists all languages", %{conn: conn, language: language} do
      {:ok, _index_live, html} = live(conn, Routes.language_index_path(conn, :index))

      assert html =~ "Listing Languages"
      assert html =~ language.slug
    end

    test "saves new language", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.language_index_path(conn, :index))

      assert index_live |> element("a", "New Language") |> render_click() =~
               "New Language"

      assert_patch(index_live, Routes.language_index_path(conn, :new))

      assert index_live
             |> form("#language-form", language: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#language-form", language: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.language_index_path(conn, :index))

      assert html =~ "Language created successfully"
      assert html =~ "some slug"
    end

    test "updates language in listing", %{conn: conn, language: language} do
      {:ok, index_live, _html} = live(conn, Routes.language_index_path(conn, :index))

      assert index_live |> element("#language-#{language.id} a", "Edit") |> render_click() =~
               "Edit Language"

      assert_patch(index_live, Routes.language_index_path(conn, :edit, language))

      assert index_live
             |> form("#language-form", language: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#language-form", language: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.language_index_path(conn, :index))

      assert html =~ "Language updated successfully"
      assert html =~ "some updated slug"
    end

    test "deletes language in listing", %{conn: conn, language: language} do
      {:ok, index_live, _html} = live(conn, Routes.language_index_path(conn, :index))

      assert index_live |> element("#language-#{language.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#language-#{language.id}")
    end
  end

  describe "Show" do
    setup [:create_language]

    test "displays language", %{conn: conn, language: language} do
      {:ok, _show_live, html} = live(conn, Routes.language_show_path(conn, :show, language))

      assert html =~ "Show Language"
      assert html =~ language.slug
    end

    test "updates language within modal", %{conn: conn, language: language} do
      {:ok, show_live, _html} = live(conn, Routes.language_show_path(conn, :show, language))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Language"

      assert_patch(show_live, Routes.language_show_path(conn, :edit, language))

      assert show_live
             |> form("#language-form", language: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#language-form", language: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.language_show_path(conn, :show, language))

      assert html =~ "Language updated successfully"
      assert html =~ "some updated slug"
    end
  end
end
