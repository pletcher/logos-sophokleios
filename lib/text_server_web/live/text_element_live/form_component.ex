defmodule TextServerWeb.TextElementLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.TextElements

  @impl true
  def update(%{text_element: text_element} = assigns, socket) do
    changeset = TextElements.change_text_element(text_element)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"text_element" => text_element_params}, socket) do
    changeset =
      socket.assigns.text_element
      |> TextElements.change_text_element(text_element_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"text_element" => text_element_params}, socket) do
    save_text_element(socket, socket.assigns.action, text_element_params)
  end

  defp save_text_element(socket, :edit, text_element_params) do
    case TextElements.update_text_element(socket.assigns.text_element, text_element_params) do
      {:ok, _text_element} ->
        {:noreply,
         socket
         |> put_flash(:info, "Text element updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_text_element(socket, :new, text_element_params) do
    case TextElements.create_text_element(text_element_params) do
      {:ok, _text_element} ->
        {:noreply,
         socket
         |> put_flash(:info, "Text element created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
