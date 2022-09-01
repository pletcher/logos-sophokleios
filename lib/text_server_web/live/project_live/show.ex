defmodule TextServerWeb.ProjectLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.Projects
  alias TextServerWeb.Components
  alias TextServerWeb.Icons

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, uri, socket) do
    %URI{
    	authority: authority,
    	scheme: scheme
    } = URI.parse(uri)

    project = Projects.get_project_with_exemplars(id)
    project_url = "#{scheme}://#{project.domain}.#{authority}"

    {:noreply,
     socket
     |> assign(:project_url, project_url)
     |> assign(:page_title, project.title)
     |> assign(:project, project)}
  end
end
