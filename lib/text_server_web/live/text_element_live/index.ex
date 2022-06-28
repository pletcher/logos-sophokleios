defmodule TextServerWeb.TextElementLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.TextElements
  alias TextServer.TextElements.TextElement

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :text_elements, list_text_elements())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Text element")
    |> assign(:text_element, TextElements.get_text_element!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Text element")
    |> assign(:text_element, %TextElement{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Text elements")
    |> assign(:text_element, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    text_element = TextElements.get_text_element!(id)
    {:ok, _} = TextElements.delete_text_element(text_element)

    {:noreply, assign(socket, :text_elements, list_text_elements())}
  end

  defp list_text_elements do
    TextElements.list_text_elements()
  end
end
