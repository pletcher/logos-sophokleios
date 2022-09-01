defmodule TextServerWeb.ExemplarLive.New do
  use TextServerWeb, :live_view

  alias TextServer.Exemplars.Exemplar
  alias TextServer.Projects
  alias TextServer.Repo
  alias TextServer.Works

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:exemplar, %Exemplar{} |> Repo.preload(:language))
     |> assign(:page_title, "Create exemplar")
     |> assign(:project, get_project!(params["id"]))
     |> assign(:selected_work, nil)
     |> assign(:works, [])}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("search_works", %{"value" => search_string}, socket) do
    page = Works.search_works(search_string)
    works = page.entries
    selected_work = Enum.find(works, fn w -> w.english_title == search_string end)

    if is_nil(selected_work) do
      {:noreply, socket |> assign(:works, page.entries)}
    else
      {:noreply, socket |> assign(:works, []) |> assign(:selected_work, selected_work)}
    end
  end

  def handle_event("reset_work_search", _params, socket) do
  	{:noreply, socket |> assign(:works, []) |> assign(:selected_work, nil)}
  end

  defp get_project!(id) do
  	Projects.get_project!(id)
  end
end
