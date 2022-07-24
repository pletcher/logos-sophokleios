defmodule TextServerWeb.ProjectLive.New do
  use TextServerWeb, :live_view

  alias TextServer.Accounts
  alias TextServer.Projects
  alias TextServer.Projects.Project

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:project, %Project{})
      |> assign(:page_title, "New Project")

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(event_name, params, socket) do
    IO.puts(event_name)
    IO.inspect(params)

    {:noreply, socket}
  end
end
