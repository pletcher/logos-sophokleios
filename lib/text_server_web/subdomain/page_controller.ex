defmodule TextServerWeb.Subdomain.PageController do
  use TextServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", %{subdomain: conn.private[:subdomain]})
  end
end
