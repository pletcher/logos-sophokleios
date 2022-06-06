defmodule TextServerWeb.TextGroupLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.TextGroups

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:text_group, TextGroups.get_text_group!(id))}
  end

  defp page_title(:show), do: "Show Text group"
  defp page_title(:edit), do: "Edit Text group"
end
