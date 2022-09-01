defmodule TextServerWeb.WorkLive.Search do
	use TextServerWeb, :live_component

	alias TextServerWeb.Components

	def render(%{label: label, on_change: on_change, on_reset: on_reset} = assigns) do
	  ~H"""
	  <div clas="w-full">
		  <%= if @selected_work do %>
		  	<Components.card item={@selected_work} url={nil}>
		  		<%= @selected_work.title %>
		  	</Components.card>

		  	<a class="text-stone-700 underline" href="#" phx-click={on_reset}>&lsaquo; Search again</a>
		  <% else %>
	  		<div>
		  		<label class="block mb-1" for="work_search" id="work_search-label"><%= label %></label>

			  	<input
			  		class=
			  			"appearance-none relative resize-none w-full py-2 mb-4 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-stone-500 focus:border-stone-500 focus:z-10 sm:text-sm"
			  		id="work_search-input"
			  		disabled={!is_nil(@selected_work)}
			  		list="work_search_results"
			  		name="work_search"
			  		phx-keyup={on_change}
			  		phx-debounce="500"
			  		placeholder="Start typing to search for a work"
			  		type="text"
			  	/>
		 		</div>

		  	<datalist id="work_search_results">
		  		<%= for work <- @works do %>
		  			<option value={work.english_title} />
		  		<% end %>
		  	</datalist>
		  <% end %>
	  </div>
	  """
	end
end
