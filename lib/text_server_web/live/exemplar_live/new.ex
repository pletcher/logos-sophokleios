defmodule TextServerWeb.ExemplarLive.New do
	use TextServerWeb, :live_view

	alias TextServer.Exemplars
	alias TextServer.Exemplars.Exemplar

	@impl true
	def mount(_params, _session, socket) do
		{:ok, socket
			|> assign(:exemplar, %Exemplar{})
			|> assign(:page_title, "Upload exemplar")}
	end

	@impl true
	def handle_params(_params, _, socket) do
		{:noreply, socket}
	end
end
