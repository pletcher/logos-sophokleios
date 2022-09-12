defmodule TextServerWeb.WorkLive.Search do
  use TextServerWeb, :live_component

  alias TextServer.TextGroups
  alias TextServer.Works
  alias TextServerWeb.Components

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       selected_work: nil,
       works: []
     )}
  end

  def handle_event("reset_search", _params, socket) do
    {:noreply, socket |> assign(selected_work: nil)}
  end

  def handle_event(
        "search_works",
        %{
          "work_search" => %{
            "search_input" => search_string,
            "selected_work" => selected_work_id
          }
        } = _params,
        socket
      ) do
    page = Works.search_works(search_string)
    works = page.entries
    text_groups = TextGroups.search_text_groups(search_string)

    text_group_works =
      Enum.flat_map(text_groups, & &1.works)
      |> Enum.sort_by(&Map.fetch(&1, :english_title))

    works = Enum.concat(works, text_group_works)

    if selected_work_id == "" do
      {:noreply, socket |> assign(:works, works)}
    else
      case Works.get_work(selected_work_id) do
        nil ->
          {:noreply, socket |> assign(:works, works)}

        work ->
          send(self(), {:selected_work, work})

          {:noreply,
           socket
           |> assign(works: [], selected_work: work)}
      end
    end
  end

  def handle_event("select_work", _params, socket) do
    {:noreply, socket}
  end

  def render(%{label: label} = assigns) do
    ~H"""
    <div clas="w-full">
      <.form
        let={f}
        for={:work_search}
        id="work_search-form"
        phx-target={@myself}
        phx-change="search_works"
        phx-submit="select_work"
      >
        <%= if @selected_work do %>
          <Components.card
            item={
              %{
                description: @selected_work.urn,
                title: @selected_work.english_title
              }
            }
            url={nil}
          >
            <%= @selected_work.title %>
          </Components.card>

          <a
            class="cursor-pointer text-stone-600 underline"
            phx-click="reset_search"
            phx-target={@myself}
          >
            &lsaquo; Search again
          </a>
        <% else %>
          <div>
            <%= label(f, :search_input, label, class: "block mb-1") %>
            <%= text_input(
              f,
              :search_input,
              class:
                "appearance-none relative resize-none w-full py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-stone-500 focus:border-stone-500 focus:z-10 sm:text-sm",
              phx_debounce: 500,
              placeholder: "Start typing to search for a work"
            ) %>
          </div>

          <%= select(
            f,
            :selected_work,
            Enum.map(@works, &[key: &1.english_title, value: &1.id]),
            class:
              "relative w-full cursor-default rounded-b-md border border-t-0 border-gray-300 bg-white py-2 pl-3 pr-10 text-left shadow-sm focus:border-stone-500 focus:outline-none focus:ring-1 focus:ring-stone-500 sm:text-sm",
            prompt: "Search for and select a work"
          ) %>
        <% end %>
      </.form>
    </div>
    """
  end
end
