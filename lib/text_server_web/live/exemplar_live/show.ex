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
  def handle_params(%{"id" => id, "page" => page_number}, _, socket) do
    %{comments: comments, footnotes: footnotes, page: page} = get_page(id, page_number)

    {:noreply,
     socket
     |> assign(
       comments: comments,
       exemplar: Exemplars.get_exemplar!(id),
       footnotes: footnotes,
       highlighted_comments: [],
       page: Map.delete(page, :text_nodes),
       page_title: page_title(socket.assigns.live_action),
       text_nodes: page.text_nodes |> TextNodes.tag_text_nodes()
     )}
  end

  def handle_params(params, session, socket) do
    handle_params(
      params |> Enum.into(%{"page" => "1"}),
      session,
      socket
    )
  end

  @impl true
  def handle_event("highlight-comments", %{"comments" => comment_ids}, socket) do
    ids =
      comment_ids
      |> Jason.decode!()
      |> Enum.map(&String.to_integer/1)

    {:noreply, socket |> assign(highlighted_comments: ids)}
  end

  defp get_page(exemplar_id, page_number) do
    page = Exemplars.get_exemplar_page(exemplar_id, String.to_integer(page_number))
    elements = page.text_nodes
      |> Enum.map(fn tn -> tn.text_elements end)
      |> List.flatten()

    comments =
      elements
      |> Enum.filter(fn te ->
        attrs = Map.get(te, :attributes)
        kv_pairs = Map.get(attrs, "key_value_pairs")

        te.element_type.name == "comment" &&
          kv_pairs["date"] != nil
      end)
      |> Enum.map(fn c ->
        attrs = Map.get(c, :attributes)
        kv_pairs = Map.get(attrs, "key_value_pairs")
        author = kv_pairs["author"]

        {:ok, date, _} = DateTime.from_iso8601(kv_pairs["date"])

        Map.merge(c, %{
          author: author,
          content: c.content,
          date: date
        })
      end)

    footnotes =
      elements
      |> Enum.filter(fn te -> te.element_type.name == "note" end)


    %{comments: comments, footnotes: footnotes, page: page}
  end

  defp page_title(:show), do: "Show Exemplar"
  defp page_title(:edit), do: "Edit Exemplar"
end
