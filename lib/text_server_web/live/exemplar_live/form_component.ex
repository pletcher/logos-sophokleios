defmodule TextServerWeb.ExemplarLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.Exemplars

  @impl true
  def update(%{exemplar: exemplar} = assigns, socket) do
    changeset = Exemplars.change_exemplar(exemplar)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
	   |> assign(:uploaded_files, [])
	   |> allow_upload(:exemplar_file, accept: ~w(.docx .xml), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"exemplar" => exemplar_params}, socket) do
    changeset =
      socket.assigns.exemplar
      |> Exemplars.change_exemplar(exemplar_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"exemplar" => exemplar_params}, socket) do
    save_exemplar(socket, socket.assigns.action, exemplar_params)
  end

  defp save_exemplar(socket, :edit, exemplar_params) do
    case Exemplars.update_exemplar(socket.assigns.exemplar, exemplar_params) do
      {:ok, _exemplar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exemplar updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_exemplar(socket, :new, exemplar_params) do
    case Exemplars.create_exemplar(exemplar_params) do
      {:ok, _exemplar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exemplar created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
