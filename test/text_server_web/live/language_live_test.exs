defmodule TextServerWeb.LanguageLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.LanguagesFixtures

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

      assert html =~ "Show"
      assert html =~ language.slug
    end
  end
end
