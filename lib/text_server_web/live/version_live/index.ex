defmodule TextServerWeb.VersionLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Versions
  alias TextServer.Versions.Version
  alias TextServerWeb.Components

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
    |> assign(:version, Versions.get_version!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Version")
    |> assign(:version, %Version{})
  end

  defp apply_action(socket, :index, params) do
    page_number = Map.get(params, "page", 1)
    versions = socket.assigns.versions

    socket =
      socket
      |> assign(:page_title, "Versions")
      |> assign(:version, nil)
      |> assign(:page_number, page_number)

    if versions.page_number == page_number do
      socket
    else
      socket
      |> assign(:versions, list_versions(page_number))
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    version = Versions.get_version!(id)
    {:ok, _} = Versions.delete_version(version)

    {:noreply, assign(socket, :versions, list_versions(socket.assigns.page_number))}
  end

  defp list_versions(page_number \\ 1) do
    Versions.list_versions(page: page_number, page_size: 20)
  end
end
