defmodule TextServerWeb.ProjectLive.Edit do
  use TextServerWeb, :live_view

  alias TextServer.Projects

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    project = Projects.get_project!(id)

    {:noreply,
     socket
     |> assign(:page_title, project.title)
     |> assign(:project, project)}
  end
end
