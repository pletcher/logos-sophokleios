defmodule TextServerWeb.ProjectLive.EditExemplars do
  use TextServerWeb, :live_view

  alias TextServer.Repo
  alias TextServer.Exemplars
  alias TextServer.Projects

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
	  project = Projects.get_project!(id) |> Repo.preload(:project_exemplars)
	  selected_exemplars = project.project_exemplars
	  # NOTE: (charles) We're assuming that most projects won't have
	  # too many exemplars.
	  selected_exemplar_ids = Enum.map(selected_exemplars, fn ex -> ex.id end)
	  %{
	    entries: entries,
	    page_number: page_number,
	    page_size: page_size,
	    total_entries: total_entries,
	    total_pages: total_pages
	  } = Exemplars.list_exemplars_except(selected_exemplar_ids)
    assigns = [
      conn: socket,
      page_number: page_number,
      page_size: page_size,
      project: project,
      selected_exemplars: selected_exemplars,
      total_entries: total_entries,
      total_pages: total_pages,
      unselected_exemplars: entries,
    ]

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    project = Projects.get_project!(id) |> Repo.preload(:project_exemplars)
    selected_exemplars = project.project_exemplars
    unselected_exemplars = Exemplars.list_exemplars_except(selected_exemplars)

    socket
    |> assign(:page_title, "Add or remove exemplars")
    |> assign(:project, project)
    |> assign(:selected_exemplars, selected_exemplars)
    |> assign(:unselected_exemplars, unselected_exemplars)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, socket}
  end
end
