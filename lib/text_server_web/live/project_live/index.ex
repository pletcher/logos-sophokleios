defmodule TextServerWeb.ProjectLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Projects
  alias TextServerWeb.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :project_collection, list_projects())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, assign(socket, :project_collection, list_projects())}
  end

  defp list_projects do
    Projects.list_projects()
  end
end
