defmodule TextServerWeb.PageController do
  use TextServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
