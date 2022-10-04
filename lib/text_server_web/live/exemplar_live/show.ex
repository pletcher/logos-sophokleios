defmodule TextServerWeb.ExemplarLive.Show do
  use TextServerWeb, :live_view

  alias TextServerWeb.Components

  alias TextServer.Exemplars
  alias TextServer.TextNodes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(
       page_title: page_title(socket.assigns.live_action),
       exemplar: Exemplars.get_exemplar!(id),
       text_nodes: TextNodes.list_text_nodes_by_exemplar_id(id),
       shown_comments: []
     )}
  end

  @impl true
  def handle_event("show-comments", %{"comments" => comment_ids}, socket) do
    comments =
      TextServer.TextElements.get_text_elements(Jason.decode!(comment_ids))
      |> Enum.map(fn c ->
        kv_pairs = Map.get(c, :attributes) |> Map.get("key_value_pairs")
        author = kv_pairs["author"]
        {:ok, date, _} = DateTime.from_iso8601(kv_pairs["date"])
        Map.new(
          author: author,
          content: c.content,
          date: date
        )
      end)

    {:noreply, socket |> assign(shown_comments: comments)}
  end

  def handle_event("hide-comments", _params, socket) do
    {:noreply, socket |> assign(shown_comments: [])}
  end

  defp page_title(:show), do: "Show Exemplar"
  defp page_title(:edit), do: "Edit Exemplar"
end
