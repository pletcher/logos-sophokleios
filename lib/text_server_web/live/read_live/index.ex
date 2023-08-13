defmodule TextServerWeb.ReadLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Collections

  alias TextServerWeb.Components

  def mount(params, _session, socket) do
    {:ok, assign(socket, :collections, list_collections(params))}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
      <h2 class="text-xl font-bold text-stone-900">Collections</h2>

      <ul role="list" class="divide-y divide-gray-200 sm:max-w-lg">
        <%= for collection <- @collections do %>
          <Components.search_list_item
            description={CTS.URN.to_string(collection.urn)}
            title={collection.title}
            url={~p"/read/#{collection.urn.namespace}"}
          />
        <% end %>
      </ul>
    </div>
    """
  end

  defp list_collections(_params) do
    Collections.list_collections_with_repositories()
  end
end
