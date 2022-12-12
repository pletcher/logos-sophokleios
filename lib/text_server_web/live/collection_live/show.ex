defmodule TextServerWeb.CollectionLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.Collections

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => collection_id} = params, _uri, socket) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } =
      TextServer.TextGroups.paginate_text_groups(collection_id, page: Map.get(params, "page", 1))

    assigns = [
      conn: socket,
      collection: Collections.get_collection!(collection_id),
      page_number: page_number,
      page_size: page_size,
      page_title: page_title(socket.assigns.live_action),
      text_groups: entries,
      total_entries: total_entries,
      total_pages: total_pages
    ]

    {:noreply, assign(socket, assigns)}
  end

  defp page_title(:show), do: "Show Collection"
  defp page_title(:edit), do: "Edit Collection"
end
