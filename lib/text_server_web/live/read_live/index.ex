defmodule TextServerWeb.ReadLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Versions

  alias TextServerWeb.Components

  def mount(params, _session, socket) do
    {:ok, assign(socket, :versions, list_versions(params))}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white">
      <div class="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
        <h2 class="text-xl font-bold text-stone-900">Results</h2>

        <ul role="list" class="divide-y divide-gray-200 sm:max-w-lg">
          <%= for version <- @versions do %>
            <Components.search_result_card
              description={version.description}
              title={version.label}
              url={~p"/versions/#{version.id}"}
            />
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp list_versions(_params) do
    Versions.list_versions()
  end
end
