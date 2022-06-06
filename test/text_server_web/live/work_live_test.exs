defmodule TextServerWeb.WorkLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.WorksFixtures

  @create_attrs %{description: "some description", english_title: "some english_title", filemd5hash: "some filemd5hash", filename: "some filename", form: "some form", full_urn: "some full_urn", label: "some label", original_title: "some original_title", slug: "some slug", structure: "some structure", urn: "some urn", work_type: :edition}
  @update_attrs %{description: "some updated description", english_title: "some updated english_title", filemd5hash: "some updated filemd5hash", filename: "some updated filename", form: "some updated form", full_urn: "some updated full_urn", label: "some updated label", original_title: "some updated original_title", slug: "some updated slug", structure: "some updated structure", urn: "some updated urn", work_type: :translation}
  @invalid_attrs %{description: nil, english_title: nil, filemd5hash: nil, filename: nil, form: nil, full_urn: nil, label: nil, original_title: nil, slug: nil, structure: nil, urn: nil, work_type: nil}

  defp create_work(_) do
    work = work_fixture()
    %{work: work}
  end

  describe "Index" do
    setup [:create_work]

    test "lists all works", %{conn: conn, work: work} do
      {:ok, _index_live, html} = live(conn, Routes.work_index_path(conn, :index))

      assert html =~ "Listing Works"
      assert html =~ work.description
    end

    test "saves new work", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.work_index_path(conn, :index))

      assert index_live |> element("a", "New Work") |> render_click() =~
               "New Work"

      assert_patch(index_live, Routes.work_index_path(conn, :new))

      assert index_live
             |> form("#work-form", work: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#work-form", work: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.work_index_path(conn, :index))

      assert html =~ "Work created successfully"
      assert html =~ "some description"
    end

    test "updates work in listing", %{conn: conn, work: work} do
      {:ok, index_live, _html} = live(conn, Routes.work_index_path(conn, :index))

      assert index_live |> element("#work-#{work.id} a", "Edit") |> render_click() =~
               "Edit Work"

      assert_patch(index_live, Routes.work_index_path(conn, :edit, work))

      assert index_live
             |> form("#work-form", work: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#work-form", work: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.work_index_path(conn, :index))

      assert html =~ "Work updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes work in listing", %{conn: conn, work: work} do
      {:ok, index_live, _html} = live(conn, Routes.work_index_path(conn, :index))

      assert index_live |> element("#work-#{work.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#work-#{work.id}")
    end
  end

  describe "Show" do
    setup [:create_work]

    test "displays work", %{conn: conn, work: work} do
      {:ok, _show_live, html} = live(conn, Routes.work_show_path(conn, :show, work))

      assert html =~ "Show Work"
      assert html =~ work.description
    end

    test "updates work within modal", %{conn: conn, work: work} do
      {:ok, show_live, _html} = live(conn, Routes.work_show_path(conn, :show, work))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Work"

      assert_patch(show_live, Routes.work_show_path(conn, :edit, work))

      assert show_live
             |> form("#work-form", work: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#work-form", work: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.work_show_path(conn, :show, work))

      assert html =~ "Work updated successfully"
      assert html =~ "some updated description"
    end
  end
end
