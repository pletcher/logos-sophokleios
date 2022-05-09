defmodule TextServerWeb.AuthorLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.Texts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:author, Texts.get_author!(id))}
  end

  defp page_title(:show), do: "Show Author"
  defp page_title(:edit), do: "Edit Author"
end
