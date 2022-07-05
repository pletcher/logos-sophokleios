defmodule TextServerWeb.CollectionLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.Collections

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _uri, socket) do
      # entries: entries,
      # page_number: page_number,
      # page_size: page_size,
      # total_entries: total_entries,
      # total_pages: total_pages
    text_group_page = TextServer.TextGroups.paginate_text_groups(collection_id: id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:collection, Collections.get_collection!(id))
     |> assign(:text_group_page, text_group_page)}
  end

  defp page_title(:show), do: "Show Collection"
  defp page_title(:edit), do: "Edit Collection"
end
