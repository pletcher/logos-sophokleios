defmodule TextServerWeb.LanguageLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.Texts

  @impl true
  def update(%{language: language} = assigns, socket) do
    changeset = Texts.change_language(language)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"language" => language_params}, socket) do
    changeset =
      socket.assigns.language
      |> Texts.change_language(language_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"language" => language_params}, socket) do
    save_language(socket, socket.assigns.action, language_params)
  end

  defp save_language(socket, :edit, language_params) do
    case Texts.update_language(socket.assigns.language, language_params) do
      {:ok, _language} ->
        {:noreply,
         socket
         |> put_flash(:info, "Language updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_language(socket, :new, language_params) do
    case Texts.create_language(language_params) do
      {:ok, _language} ->
        {:noreply,
         socket
         |> put_flash(:info, "Language created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
