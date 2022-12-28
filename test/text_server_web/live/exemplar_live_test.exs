defmodule TextServerWeb.ExemplarLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.ExemplarsFixtures

  alias TextServer.Versions

  defp create_exemplar(_) do
    exemplar = exemplar_fixture()
    %{exemplar: exemplar}
  end

  describe "Show" do
    setup [:create_exemplar]

    test "displays exemplar", %{conn: conn, exemplar: exemplar} do
      {:ok, _show_live, html} = live(conn, Routes.exemplar_show_path(conn, :show, exemplar))

      version = Versions.get_version!(exemplar.version_id)

      assert html =~ version.description
    end
  end
end
