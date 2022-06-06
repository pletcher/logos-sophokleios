defmodule TextServerWeb.TextNodeLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.TextNodes

  @impl true
  def update(%{text_node: text_node} = assigns, socket) do
    changeset = TextNodes.change_text_node(text_node)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"text_node" => text_node_params}, socket) do
    changeset =
      socket.assigns.text_node
      |> TextNodes.change_text_node(text_node_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"text_node" => text_node_params}, socket) do
    save_text_node(socket, socket.assigns.action, text_node_params)
  end

  defp save_text_node(socket, :edit, text_node_params) do
    case TextNodes.update_text_node(socket.assigns.text_node, text_node_params) do
      {:ok, _text_node} ->
        {:noreply,
         socket
         |> put_flash(:info, "Text node updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_text_node(socket, :new, text_node_params) do
    case TextNodes.create_text_node(text_node_params) do
      {:ok, _text_node} ->
        {:noreply,
         socket
         |> put_flash(:info, "Text node created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
