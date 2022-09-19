defmodule TextServerWeb.ExemplarLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.Exemplars
  alias TextServer.TextNodes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(
       page_title: page_title(socket.assigns.live_action),
       exemplar: Exemplars.get_exemplar!(id),
       text_nodes: TextNodes.list_text_nodes_by_exemplar_id(id)
     )}
  end

  defp page_title(:show), do: "Show Exemplar"
  defp page_title(:edit), do: "Edit Exemplar"
end
