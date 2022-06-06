defmodule TextServerWeb.TextNodeLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.TextNodes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:text_node, TextNodes.get_text_node!(id))}
  end

  defp page_title(:show), do: "Show Text node"
  defp page_title(:edit), do: "Edit Text node"
end
