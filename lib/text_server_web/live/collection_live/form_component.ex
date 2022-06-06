defmodule TextServerWeb.CollectionLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.Collections

  @impl true
  def update(%{collection: collection} = assigns, socket) do
    changeset = Collections.change_collection(collection)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"collection" => collection_params}, socket) do
    changeset =
      socket.assigns.collection
      |> Collections.change_collection(collection_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"collection" => collection_params}, socket) do
    save_collection(socket, socket.assigns.action, collection_params)
  end

  defp save_collection(socket, :edit, collection_params) do
    case Collections.update_collection(socket.assigns.collection, collection_params) do
      {:ok, _collection} ->
        {:noreply,
         socket
         |> put_flash(:info, "Collection updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_collection(socket, :new, collection_params) do
    case Collections.create_collection(collection_params) do
      {:ok, _collection} ->
        {:noreply,
         socket
         |> put_flash(:info, "Collection created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
