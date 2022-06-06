defmodule TextServerWeb.CollectionLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Collections
  alias TextServer.Collections.Collection

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :collections, list_collections())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Collection")
    |> assign(:collection, Collections.get_collection!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Collection")
    |> assign(:collection, %Collection{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Collections")
    |> assign(:collection, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    collection = Collections.get_collection!(id)
    {:ok, _} = Collections.delete_collection(collection)

    {:noreply, assign(socket, :collections, list_collections())}
  end

  defp list_collections do
    Collections.list_collections()
  end
end
