defmodule TextServerWeb.RefsDeclLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.RefsDecls

  @impl true
  def update(%{refs_decl: refs_decl} = assigns, socket) do
    changeset = RefsDecls.change_refs_decl(refs_decl)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"refs_decl" => refs_decl_params}, socket) do
    changeset =
      socket.assigns.refs_decl
      |> RefsDecls.change_refs_decl(refs_decl_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"refs_decl" => refs_decl_params}, socket) do
    save_refs_decl(socket, socket.assigns.action, refs_decl_params)
  end

  defp save_refs_decl(socket, :edit, refs_decl_params) do
    case RefsDecls.update_refs_decl(socket.assigns.refs_decl, refs_decl_params) do
      {:ok, _refs_decl} ->
        {:noreply,
         socket
         |> put_flash(:info, "Refs decl updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_refs_decl(socket, :new, refs_decl_params) do
    case RefsDecls.create_refs_decl(refs_decl_params) do
      {:ok, _refs_decl} ->
        {:noreply,
         socket
         |> put_flash(:info, "Refs decl created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
