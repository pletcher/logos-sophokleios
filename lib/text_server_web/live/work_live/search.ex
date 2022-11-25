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
            "search_input" => search_string
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

    {:noreply, socket |> assign(works: works, search_string: search_string)}
  end

  def handle_event("select_work", %{"work_search" => %{"selected_work" => id}}, socket) do
    work = Works.get_work!(id)
    {:noreply, socket |> assign(selected_work: work)}
  end

  attr :label, :string, required: true
  attr :search_string, :string, default: ""

  slot :hidden_work_id, required: true

  def render(%{label: label, search_string: s} = assigns) do
    ~H"""
    <div clas="w-full">
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

        <%= render_slot(@hidden_work_id, @selected_work) %>
      <% else %>
        <div>
          <%= label(:work_search, :search_input, label, class: "block mb-1") %>
          <%= text_input(
            :work_search,
            :search_input,
            class:
              "appearance-none relative resize-none w-full py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-stone-500 focus:border-stone-500 focus:z-10 sm:text-sm",
            phx_change: "search_works",
            phx_debounce: 500,
            phx_target: @myself,
            placeholder: "Start typing to search for a work",
            value: s
          ) %>
        </div>

        <%= select(
          :work_search,
          :selected_work,
          Enum.map(@works, &[key: &1.english_title, value: &1.id]),
          class:
            "relative w-full cursor-default rounded-b-md border border-t-0 border-gray-300 bg-white py-2 pl-3 pr-10 text-left shadow-sm focus:border-stone-500 focus:outline-none focus:ring-1 focus:ring-stone-500 sm:text-sm",
          phx_change: "select_work",
          phx_target: @myself,
          prompt: "Search for and select a work"
        ) %>
      <% end %>
    </div>
    """
  end
end
