defmodule TextServerWeb.ReadingEnvironment.LocationForm do
  use TextServerWeb, :live_component

  alias TextServerWeb.Components

  attr :second_level_toc, :list
  attr :selected, :any, default: nil
  attr :versions, :list, required: true
  attr :top_level_toc, :list, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={%{}} phx-change="location-change" phx-submit="change-location">
        <Components.select_dropdown
          classes="w-full max-w-full min-w-full"
          form={f}
          name={:version_select}
          options={@versions}
          selected={@selected}
        />
        <section class="flex">
          <Components.select_dropdown form={f} name={:top_level_location} options={@top_level_toc} />
          <%= unless is_nil(@second_level_toc) do %>
            <div class="mr-2" />
            <Components.select_dropdown form={f} name={:second_level_location} options={@second_level_toc} />
          <% end %>

          <%= submit("Go", class: ~w(
            mb-4
            ml-2
            px-4
            border
            border-transparent
            text-sm
            font-medium
            text-white
            bg-stone-600
            hover:bg-stone-700
            focus:outline-none
            focus:ring-2
            focus:ring-offset-2
            focus:ring-stone-500
          )) %>
        </section>
      </.form>
    </div>
    """
  end
end
