defmodule TextServerWeb.TextNodeLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.TextNodes
  alias TextServer.TextNodes.TextNode

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :text_nodes, list_text_nodes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Text node")
    |> assign(:text_node, TextNodes.get_text_node!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Text node")
    |> assign(:text_node, %TextNode{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Text nodes")
    |> assign(:text_node, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    text_node = TextNodes.get_text_node!(id)
    {:ok, _} = TextNodes.delete_text_node(text_node)

    {:noreply, assign(socket, :text_nodes, list_text_nodes())}
  end

  defp list_text_nodes do
    TextNodes.list_text_nodes()
  end
end
