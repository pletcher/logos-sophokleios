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
    create_reply(socket, id, get_page(id, page_number))
  end

  def handle_params(%{"id" => id, "location" => raw_location}, _session, socket) do
    location = raw_location |> String.split(".") |> Enum.map(&String.to_integer/1)

    create_reply(socket, id, get_page_by_location(id, location))
  end

  def handle_params(params, session, socket) do
    handle_params(
      params |> Enum.into(%{"page" => "1"}),
      session,
      socket
    )
  end

  defp create_reply(socket, exemplar_id, page) do
    %{comments: comments, footnotes: footnotes, page: page} = page

    exemplar = Exemplars.get_exemplar!(exemplar_id)
    text_nodes = page.text_nodes
    location = List.first(text_nodes).location
    top_level_location = List.first(location)
    second_level_location = Enum.at(location, 1)

    {top_level_toc, second_level_toc} =
      if length(location) > 2 do
        format_toc(exemplar_id, top_level_location, second_level_location)
      else
        format_toc(exemplar_id, top_level_location)
      end

    {:noreply,
     socket
     |> assign(
       comments: comments,
       exemplar: exemplar,
       footnotes: footnotes,
       highlighted_comments: [],
       location: %{
         "top_level_location" => top_level_location,
         "second_level_location" => second_level_location
       },
       page: Map.delete(page, :text_nodes),
       page_title: page_title(socket.assigns.live_action),
       text_nodes: text_nodes |> TextNodes.tag_text_nodes(),
       top_level_toc: top_level_toc,
       second_level_toc: second_level_toc
     )}
  end

  defp format_toc(exemplar_id, top_level_location, second_level_location) do
    toc = Exemplars.get_table_of_contents(exemplar_id)

    top_level_toc =
      Map.keys(toc)
      |> Enum.sort()
      |> Enum.map(&[key: "Book #{&1}", value: &1, selected: &1 == top_level_location])

    second_level_toc =
      Map.get(toc, top_level_location)
      |> Map.keys()
      |> Enum.sort()
      |> Enum.map(&[key: "Chapter #{&1}", value: &1, selected: &1 == second_level_location])

    {top_level_toc, second_level_toc}
  end
  
  defp format_toc(exemplar_id, top_level_location) do
    toc = Exemplars.get_table_of_contents(exemplar_id)

    top_level_toc =
      Map.keys(toc)
      |> Enum.sort()
      |> Enum.map(&[key: "Book #{&1}", value: &1, selected: &1 == top_level_location])
    
    {top_level_toc, nil}
  end

  @impl true
  def handle_event("highlight-comments", %{"comments" => comment_ids}, socket) do
    ids =
      comment_ids
      |> Jason.decode!()
      |> Enum.map(&String.to_integer/1)

    {:noreply, socket |> assign(highlighted_comments: ids)}
  end

  def handle_event("top-level-location-change", %{"location" => location}, socket) do
    exemplar = socket.assigns.exemplar
    top_level = Map.get(location, "top_level_location") |> String.to_integer()

    {top_level_toc, second_level_toc} = format_toc(exemplar.id, top_level, 1)

    {:noreply, socket |> assign(top_level_toc: top_level_toc, second_level_toc: second_level_toc)}
  end

  def handle_event("change-location", %{"location" => location}, socket) do
    top_level = Map.get(location, "top_level_location")
    second_level = Map.get(location, "second_level_location")
    exemplar = socket.assigns.exemplar
    location_s = "#{top_level}.#{second_level}.1"

    {:noreply, socket |> push_patch(to: "/exemplars/#{exemplar.id}?location=#{location_s}")}
  end

  defp get_page(exemplar_id, page_number) when is_binary(page_number),
    do: get_page(exemplar_id, String.to_integer(page_number))

  defp get_page(exemplar_id, page_number) do
    page = Exemplars.get_exemplar_page(exemplar_id, page_number)

    organize_page(page)
  end

  defp get_page_by_location(exemplar_id, location) when is_list(location) do
    page = Exemplars.get_exemplar_page_by_location(exemplar_id, location)

    organize_page(page)
  end

  defp organize_page(page) do
    elements =
      page.text_nodes
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
