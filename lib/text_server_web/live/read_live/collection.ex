defmodule TextServerWeb.ReadLive.Collection do
  use TextServerWeb, :live_view

  alias TextServer.TextGroups

  alias TextServerWeb.Components

  def mount(%{"namespace" => namespace}, _session, socket) do
    {:ok, assign(socket, :text_groups, list_text_groups(namespace))}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
      <h2 class="text-xl font-bold text-stone-900">Text Groups</h2>

      <ul role="list" class="divide-y divide-gray-200 sm:max-w-lg">
        <%= for text_group <- @text_groups do %>
          <Components.search_list_item
            description={CTS.URN.to_string(text_group.urn)}
            title={text_group.title}
            url={~p"/read/#{text_group.urn.namespace}/#{text_group.urn.text_group}"}
          />
        <% end %>
      </ul>

      <Components.pagination current_page={@text_groups.page_number} total_pages={@text_groups.total_pages} />
    </div>
    """
  end

  defp apply_action(socket, :index, params) do
    ns = Map.get(params, "namespace")
    page_number = Map.get(params, "page", 1)
    assign(socket, :text_groups, list_text_groups(ns, [page: page_number]))
  end

  defp list_text_groups(namespace, opts \\ [page: 1]) do
    TextGroups.list_text_groups_for_namespace(namespace, opts)
  end
end
