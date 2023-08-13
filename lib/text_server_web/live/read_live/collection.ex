defmodule TextServerWeb.ReadLive.Collection do
  use TextServerWeb, :live_view

  alias TextServer.TextGroups

  alias TextServerWeb.Components

  def mount(%{"namespace" => namespace}, _session, socket) do
    {:ok, assign(socket, :text_groups, list_text_groups(namespace))}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
      <h2 class="text-xl font-bold text-stone-900">Collections</h2>

      <ul role="list" class="divide-y divide-gray-200 sm:max-w-lg">
        <%= for text_group <- @text_groups do %>
          <Components.search_list_item
            description={CTS.URN.to_string(text_group.urn)}
            title={text_group.title}
            url={~p"/read/#{text_group.urn.namespace}/#{text_group.urn.text_group}"}
          />
        <% end %>
      </ul>
    </div>
    """
  end

  defp list_text_groups(namespace) do
    TextGroups.list_text_groups_for_namespace(namespace)
  end
end
