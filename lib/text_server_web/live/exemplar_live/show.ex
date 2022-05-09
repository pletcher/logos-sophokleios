defmodule TextServerWeb.ExemplarLive.Show do
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
     |> assign(:exemplar, Texts.get_exemplar!(id))}
  end

  defp page_title(:show), do: "Show Exemplar"
  defp page_title(:edit), do: "Edit Exemplar"
end
