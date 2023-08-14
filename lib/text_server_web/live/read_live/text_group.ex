defmodule TextServerWeb.ReadLive.TextGroup do
  use TextServerWeb, :live_view

  alias TextServer.Works

  alias TextServerWeb.Components

  def mount(%{"namespace" => namespace, "text_group" => text_group}, _session, socket) do
    {:ok, assign(socket, :works, list_works(namespace, text_group))}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
      <h2 class="text-xl font-bold text-stone-900">Works</h2>

      <ul role="list" class="divide-y divide-gray-200 sm:max-w-lg">
        <%= for work <- @works do %>
          <Components.search_list_item
            description={CTS.URN.to_string(work.urn)}
            title={work.title}
            url={~p"/read/#{work.urn.namespace}/#{work.urn.text_group}"}
          />
        <% end %>
      </ul>

      <Components.pagination current_page={@works.page_number} total_pages={@works.total_pages} />
    </div>
    """
  end

  defp apply_action(socket, :index, params) do
    namespace = Map.get(params, "namespace")
    text_group = Map.get(params, "text_group")
    page_number = Map.get(params, "page", 1)
    assign(socket, :works, list_works(namespace, text_group, [page: page_number]))
  end

  defp list_works(namespace, text_group, opts \\ [page: 1]) do
    Works.list_works_for_urn(namespace, text_group, opts)
  end
end
