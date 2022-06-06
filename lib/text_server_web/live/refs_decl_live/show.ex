defmodule TextServerWeb.RefsDeclLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.RefsDecls

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:refs_decl, RefsDecls.get_refs_decl!(id))}
  end

  defp page_title(:show), do: "Show Refs decl"
  defp page_title(:edit), do: "Edit Refs decl"
end
