defmodule TextServerWeb.TextGroupLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.Texts

  @impl true
  def update(%{text_group: text_group} = assigns, socket) do
    changeset = Texts.change_text_group(text_group)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"text_group" => text_group_params}, socket) do
    changeset =
      socket.assigns.text_group
      |> Texts.change_text_group(text_group_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"text_group" => text_group_params}, socket) do
    save_text_group(socket, socket.assigns.action, text_group_params)
  end

  defp save_text_group(socket, :edit, text_group_params) do
    case Texts.update_text_group(socket.assigns.text_group, text_group_params) do
      {:ok, _text_group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Text group updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_text_group(socket, :new, text_group_params) do
    case Texts.create_text_group(text_group_params) do
      {:ok, _text_group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Text group created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
