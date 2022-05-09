defmodule TextServerWeb.VersionLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Texts
  alias TextServer.Texts.Version

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :versions, list_versions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Version")
    |> assign(:version, Texts.get_version!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Version")
    |> assign(:version, %Version{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Versions")
    |> assign(:version, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    version = Texts.get_version!(id)
    {:ok, _} = Texts.delete_version(version)

    {:noreply, assign(socket, :versions, list_versions())}
  end

  defp list_versions do
    Texts.list_versions()
  end
end
