defmodule TextServerWeb.ProjectLive.EditExemplars do
	use TextServerWeb, :live_view

	alias TextServer.Exemplars
	alias TextServer.Projects

	@impl true
	def mount(_params, _session, socket) do
	  {:ok, socket}
	end

	@impl true
	def handle_params(params, _url, socket) do
	  {:noreply, apply_action(socket, socket.assigns.live_action, params)}
	end

	defp apply_action(socket, :edit, %{"id" => id}) do
	  socket
	  # |> assign(:page_title, "Edit Project")
	  # |> assign(:project, Projects.get_project!(id))
	end

	@impl true
	def handle_event("delete", %{"id" => id}, socket) do
	  project = Projects.get_project!(id)
	  {:ok, _} = Projects.delete_project(project)

	  {:noreply, socket}
	end
end
