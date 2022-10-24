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
    text_nodes = TextNodes.list_text_nodes_by_exemplar_id(id)

    comments =
      text_nodes
      |> Enum.map(fn tn -> tn.text_elements end)
      |> List.flatten()
      |> Enum.filter(fn te ->
        kv_pairs = Map.get(te, :attributes) |> Map.get("key_value_pairs")

        te.element_type.name == "comment" && kv_pairs["date"] != nil
      end)
      |> Enum.map(fn c ->
        kv_pairs = Map.get(c, :attributes) |> Map.get("key_value_pairs")
        author = kv_pairs["author"]

        {:ok, date, _} = DateTime.from_iso8601(kv_pairs["date"])

        Map.merge(c, %{
          author: author,
          content: c.content,
          date: date
        })
      end)

    {:noreply,
     socket
     |> assign(
       page_title: page_title(socket.assigns.live_action),
       exemplar: Exemplars.get_exemplar!(id),
       text_nodes: text_nodes |> TextNodes.tag_text_nodes(),
       comments: comments,
       highlighted_comments: []
     )}
  end

  @impl true
  def handle_event("highlight-comments", %{"comments" => comment_ids}, socket) do
    ids =
      comment_ids
      |> Jason.decode!()
      |> Enum.map(&String.to_integer/1)

    {:noreply, socket |> assign(highlighted_comments: ids)}
  end

  defp page_title(:show), do: "Show Exemplar"
  defp page_title(:edit), do: "Edit Exemplar"
end
