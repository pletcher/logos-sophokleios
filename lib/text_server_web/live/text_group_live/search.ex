defmodule TextServerWeb.TextGroupLive.Search do
  use TextServerWeb, :live_component

  alias TextServer.TextGroups
  alias TextServerWeb.Components

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       selected_text_group: nil,
       text_groups: []
     )}
  end

  def handle_event("reset_search", _params, socket) do
    {:noreply, socket |> assign(selected_text_group: nil)}
  end

  def handle_event(
        "search_text_groups",
        %{
          "text_group_search" => %{
            "search_input" => search_string,
            "selected_text_group" => selected_text_group_id
          }
        } = _params,
        socket
      ) do
    text_groups = TextGroups.search_text_groups(search_string)

    if selected_text_group_id == "" do
      {:noreply, socket |> assign(:text_groups, text_groups)}
    else
      text_group = TextGroups.get_text_group!(selected_text_group_id)
      send(self(), {:selected_text_group, text_group})

      {:noreply,
       socket
       |> assign(text_groups: [], selected_text_group: text_group)}
    end
  end

  def handle_event("select_text_group", _params, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div clas="w-full">
      <.form
        :let={f}
        for={%{}}
        as={:text_group_search}
        id="text_group_search-form"
        phx-target={@myself}
        phx-change="search_text_groups"
        phx-submit="select_text_group"
      >
        <%= if @selected_text_group do %>
          <Components.card
            item={
              %{
                description: @selected_text_group.urn,
                title: @selected_text_group.title
              }
            }
            url={""}
          >
            <%= @selected_text_group.title %>
          </Components.card>

          <a class="cursor-pointer text-stone-600 underline" phx-click="reset_search" phx-target={@myself}>
            &lsaquo; Search again
          </a>
        <% else %>
          <div>
            <%= label(f, :search_input, @label, class: "block mb-1") %>
            <%= text_input(
              f,
              :search_input,
              class:
                "appearance-none relative resize-none w-full py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-stone-500 focus:border-stone-500 focus:z-10 sm:text-sm",
              phx_debounce: 500,
              placeholder: "Start typing to search for a text group"
            ) %>
          </div>

          <%= select(
            f,
            :selected_text_group,
            Enum.map(@text_groups, &[key: &1.title, value: &1.id]),
            class:
              "relative w-full cursor-default rounded-b-md border border-t-0 border-gray-300 bg-white py-2 pl-3 pr-10 text-left shadow-sm focus:border-stone-500 focus:outline-none focus:ring-1 focus:ring-stone-500 sm:text-sm",
            prompt: "Search for and select a text group"
          ) %>
        <% end %>
      </.form>
    </div>
    """
  end
end
