defmodule TextServerWeb.TranslationLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.Texts

  @impl true
  def update(%{translation: translation} = assigns, socket) do
    changeset = Texts.change_translation(translation)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"translation" => translation_params}, socket) do
    changeset =
      socket.assigns.translation
      |> Texts.change_translation(translation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"translation" => translation_params}, socket) do
    save_translation(socket, socket.assigns.action, translation_params)
  end

  defp save_translation(socket, :edit, translation_params) do
    case Texts.update_translation(socket.assigns.translation, translation_params) do
      {:ok, _translation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Translation updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_translation(socket, :new, translation_params) do
    case Texts.create_translation(translation_params) do
      {:ok, _translation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Translation created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
