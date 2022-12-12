defmodule TextServerWeb.ProjectLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.Projects
  alias TextServerWeb.Icons
  alias TextServerWeb.Helpers.Markdown

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:project_image, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
  end

  @impl true
  def update(%{project: project} = assigns, socket) do
    changeset = Projects.change_project(project)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:markdown_preview, Markdown.sanitize_and_parse_markdown(project.homepage_copy))
     |> assign(:raw_markdown, project.homepage_copy)}
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset =
      socket.assigns.project
      |> Projects.change_project(project_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:raw_markdown, project_params["homepage_copy"])}
  end

  def handle_event("render_markdown", %{"raw_markdown" => raw_markdown}, socket) do
    html = Markdown.sanitize_and_parse_markdown(raw_markdown)

    {:noreply, socket |> assign(:markdown_preview, html)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.action, project_params)
  end

  defp save_project(socket, :edit, project_params) do
    case Projects.update_project(socket.assigns.project, project_params) do
      {:ok, _project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_project(socket, :new, project_params) do
    case Projects.create_project(project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project created successfully")
         |> push_redirect(to: Routes.project_show_path(socket, :show, project))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket |> put_flash(:error, "Error creating project") |> assign(changeset: changeset)}
    end
  end
end
