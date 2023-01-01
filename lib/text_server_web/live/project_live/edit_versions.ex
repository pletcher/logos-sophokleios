defmodule TextServerWeb.ProjectLive.EditVersions do
  use TextServerWeb, :live_view

  alias TextServer.Repo
  alias TextServer.Versions
  alias TextServer.Projects

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    project = Projects.get_project!(id) |> Repo.preload(:project_versions)
    selected_versions = project.project_versions
    # NOTE: (charles) We're assuming that most projects won't have
    # too many versions.
    selected_version_ids = Enum.map(selected_versions, fn ex -> ex.id end)

    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Versions.list_versions_except(selected_version_ids)

    assigns = [
      conn: socket,
      page_number: page_number,
      page_size: page_size,
      project: project,
      selected_versions: selected_versions,
      total_entries: total_entries,
      total_pages: total_pages,
      unselected_versions: entries
    ]

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    project = Projects.get_project!(id) |> Repo.preload(:project_versions)
    selected_versions = project.project_versions
    unselected_versions = Versions.list_versions_except(selected_versions |> Enum.map(& &1.id))

    socket
    |> assign(:page_title, "Add or remove versions")
    |> assign(:project, project)
    |> assign(:selected_versions, selected_versions)
    |> assign(:unselected_versions, unselected_versions)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, socket}
  end
end
