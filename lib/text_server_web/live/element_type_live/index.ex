defmodule TextServerWeb.ElementTypeLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.ElementTypes
  alias TextServer.ElementTypes.ElementType

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :element_types, list_element_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Element type")
    |> assign(:element_type, ElementTypes.get_element_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Element type")
    |> assign(:element_type, %ElementType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Element types")
    |> assign(:element_type, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    element_type = ElementTypes.get_element_type!(id)
    {:ok, _} = ElementTypes.delete_element_type(element_type)

    {:noreply, assign(socket, :element_types, list_element_types())}
  end

  defp list_element_types do
    ElementTypes.list_element_types()
  end
end
