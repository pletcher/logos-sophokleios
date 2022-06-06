defmodule TextServerWeb.WorkLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.Works

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:work, Works.get_work!(id))}
  end

  defp page_title(:show), do: "Show Work"
  defp page_title(:edit), do: "Edit Work"
end
