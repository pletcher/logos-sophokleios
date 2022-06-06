defmodule TextServerWeb.ExemplarLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Exemplars
  alias TextServer.Exemplars.Exemplar

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :exemplars, list_exemplars())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Exemplar")
    |> assign(:exemplar, Exemplars.get_exemplar!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Exemplar")
    |> assign(:exemplar, %Exemplar{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Exemplars")
    |> assign(:exemplar, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    exemplar = Exemplars.get_exemplar!(id)
    {:ok, _} = Exemplars.delete_exemplar(exemplar)

    {:noreply, assign(socket, :exemplars, list_exemplars())}
  end

  defp list_exemplars do
    Exemplars.list_exemplars()
  end
end
