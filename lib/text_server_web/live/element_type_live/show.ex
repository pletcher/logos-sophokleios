defmodule TextServerWeb.ElementTypeLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.ElementTypes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:element_type, ElementTypes.get_element_type!(id))}
  end

  defp page_title(:show), do: "Show Element type"
  defp page_title(:edit), do: "Edit Element type"
end
