defmodule TextServerWeb.Components do
  use TextServerWeb, :component

  def card(%{item: item, url: url} = assigns) do
    ~H"""
    <div class="group relative">
      <div class="w-full min-h-80 bg-gray-200 aspect-w-1 aspect-h-1 rounded-md overflow-hidden group-hover:opacity-75 lg:h-80 lg:aspect-none">
        <p class="align-text-center flex items-center justify-center w-full h-full text-9xl">
          <%= render_slot(@inner_block) %>
        </p>
      </div>
      <div class="mt-4 flex justify-between">
        <div>
          <h3 class="font-bold text-gray-700">
            <a href={url}>
              <span aria-hidden="true" class="absolute inset-0"></span> <%= item.title %>
            </a>
          </h3>
          <p class="mt-1 text-sm text-gray-500"><%= item.description %></p>
        </div>
      </div>
    </div>
    """
  end

  attr :click_away, :string, required: true
  attr :comments, :list, default: []

  def floating_comments(%{comments: comments, click_away: click_away} = assigns) do
    ~H"""
    <div class="overflow-scroll bg-white shadow sm:rounded-lg" phx-click-away={click_away}>
      <div class="px-4 py-5 sm:px-6">
        <%= for c <- comments do %>
          <h3 class="text-lg font-medium leading-6 text-gray-900"><%= c.author %></h3>
          <small class="mt-1 mx-w-2xl text-sm text-gray-500"><%= c.date %></small>
          <p class="mt-1 max-w-2xl text-sm text-gray-800"><%= c.content %></p>
        <% end %>
      </div>
    </div>
    """
  end

  def small_card(%{item: item, url: url} = assigns) do
    ~H"""
    <div class="flex py-6">
      <div class="h-24 w-24 flex-shrink-0 overflow-hidden rounded-md border border-gray-200">
        <img
          src="https://www.fillmurray.com/480/480"
          class="h-full w-full object-cover object-center"
        />
      </div>

      <div class="ml-4 flex flex-1 flex-col">
        <div>
          <div class="flex justify-between text-base font-medium text-gray-900">
            <h3>
              <a href={url}><%= item.title %></a>
            </h3>
          </div>
        </div>
        <div class="flex flex-1 justify-between text-sm">
          <p class="text-sm text-gray-500"><%= item.description %></p>
        </div>
      </div>
    </div>
    """
  end
end
