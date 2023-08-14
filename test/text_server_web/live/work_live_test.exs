defmodule TextServerWeb.WorkLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.TextGroupsFixtures
  import TextServer.WorksFixtures

  @create_attrs %{
    description: "some description",
    english_title: "some english_title",
    original_title: "some original_title",
    urn: "urn:cts:namespace:text_group.work",
    cts_urn: CTS.URN.parse("urn:cts:namespace:text_group.work")
  }
  @update_attrs %{
    description: "some updated description",
    english_title: "some updated english_title",
    original_title: "some updated original_title",
    urn: "urn:cts:namespace:text_group.updated_work",
    cts_urn: CTS.URN.parse("urn:cts:namespace:text_group.updated_work")
  }
  @invalid_attrs %{
    description: nil,
    english_title: nil,
    original_title: nil,
    urn: nil
  }

  defp create_text_group(_) do
    text_group = text_group_fixture()
    %{text_group: text_group}
  end

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

    # test "updates work in listing", %{conn: conn, work: work} do
    #   {:ok, index_live, _html} = live(conn, Routes.work_index_path(conn, :index))

    #   assert index_live |> element("#work-#{work.id} a", "Edit") |> render_click() =~
    #            "Edit Work"

    #   assert_patch(index_live, Routes.work_index_path(conn, :edit, work))

    #   assert index_live
    #          |> form("#work-form", work: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   {:ok, _, html} =
    #     index_live
    #     |> form("#work-form", work: @update_attrs)
    #     |> render_submit()
    #     |> follow_redirect(conn, Routes.work_index_path(conn, :index))

    #   assert html =~ "Work updated successfully"
    #   assert html =~ "some updated description"
    # end

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

    @tag :skip
    test "updates work within modal", %{conn: conn, work: work} do
      user = TextServer.AccountsFixtures.user_fixture()
      conn = log_in_user(conn, user)

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

  describe "New" do
    setup [:create_text_group]

    @tag skip: "Skipping until URN migration is completed"
    test "saves new work", %{conn: conn, text_group: text_group} do
      user = TextServer.AccountsFixtures.user_fixture()
      conn = log_in_user(conn, user)

      {:ok, new_live, _html} = live(conn, Routes.work_new_path(conn, :new))

      assert new_live
             |> form("#work-form", work: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      send(new_live.pid, {:selected_text_group, text_group})

      {:ok, _, html} =
        new_live
        |> form("#work-form", work: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.work_index_path(conn, :index))

      assert html =~ "Work created successfully"
      assert html =~ "some description"
    end
  end
end
