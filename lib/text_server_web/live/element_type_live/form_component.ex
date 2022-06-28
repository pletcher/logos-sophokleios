defmodule TextServerWeb.ElementTypeLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.ElementTypes

  @impl true
  def update(%{element_type: element_type} = assigns, socket) do
    changeset = ElementTypes.change_element_type(element_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"element_type" => element_type_params}, socket) do
    changeset =
      socket.assigns.element_type
      |> ElementTypes.change_element_type(element_type_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"element_type" => element_type_params}, socket) do
    save_element_type(socket, socket.assigns.action, element_type_params)
  end

  defp save_element_type(socket, :edit, element_type_params) do
    case ElementTypes.update_element_type(socket.assigns.element_type, element_type_params) do
      {:ok, _element_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Element type updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_element_type(socket, :new, element_type_params) do
    case ElementTypes.create_element_type(element_type_params) do
      {:ok, _element_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Element type created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
