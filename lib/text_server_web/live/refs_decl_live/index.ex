defmodule TextServerWeb.RefsDeclLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Texts
  alias TextServer.Texts.RefsDecl

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :refs_decls, list_refs_decls())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Refs decl")
    |> assign(:refs_decl, Texts.get_refs_decl!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Refs decl")
    |> assign(:refs_decl, %RefsDecl{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Refs decls")
    |> assign(:refs_decl, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    refs_decl = Texts.get_refs_decl!(id)
    {:ok, _} = Texts.delete_refs_decl(refs_decl)

    {:noreply, assign(socket, :refs_decls, list_refs_decls())}
  end

  defp list_refs_decls do
    Texts.list_refs_decls()
  end
end
