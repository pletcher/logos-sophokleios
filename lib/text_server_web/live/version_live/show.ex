defmodule TextServerWeb.VersionLive.Show do
  use TextServerWeb, :live_view

  alias TextServerWeb.Components

  alias TextServer.Repo
  alias TextServer.Versions
  alias TextServer.TextNodes

  @internal_commentary_magic_string "@@oc/commentary"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(%{"id" => id, "page" => passage_number}, _, socket) do
    create_response(socket, id, get_passage(id, passage_number))
  end

  def handle_params(%{"id" => id, "location" => raw_location}, _session, socket) do
    location = raw_location |> String.split(".") |> Enum.map(&String.to_integer/1)

    create_response(socket, id, get_passage_by_location(id, location))
  end

  def handle_params(params, session, socket) do
    handle_params(
      params |> Enum.into(%{"page" => "1"}),
      session,
      socket
    )
  end

  defp create_response(socket, version_id, page) do
    %{comments: comments, footnotes: footnotes, passage: passage} = page

    version = Versions.get_version!(version_id) |> Repo.preload(:language)
    text_nodes = passage.text_nodes
    location = List.first(text_nodes).location
    top_level_location = List.first(location)
    second_level_location = Enum.at(location, 1)

    {top_level_toc, second_level_toc} =
      if length(location) > 2 do
        format_toc(version_id, top_level_location, second_level_location)
      else
        format_toc(version_id, top_level_location)
      end

    {:noreply,
     socket
     |> assign(
       comments: comments,
       footnotes: footnotes,
       highlighted_comments: [],
       location: %{
         "top_level_location" => top_level_location,
         "second_level_location" => second_level_location
       },
       passage: Map.delete(passage, :text_nodes),
       page_title: page_title(socket.assigns.live_action),
       text_nodes: text_nodes |> TextNodes.tag_text_nodes(),
       top_level_toc: top_level_toc,
       second_level_toc: second_level_toc,
       version: version
     )
     |> sync_second_reader()}
  end

  def sync_second_reader(socket) do
    version = socket.assigns.version
    sibling_versions = Versions.list_sibling_versions(version)

    second_reader_options = [
      {"This project's commentary", @internal_commentary_magic_string}
      | sibling_versions
        |> Enum.map(fn v ->
          {v.label, v.id}
        end)
    ]

    socket
    |> assign_new(:second_reader_selection, fn -> @internal_commentary_magic_string end)
    |> assign(
      second_reader_options: second_reader_options,
      second_reader_text_nodes: list_second_reader_text_nodes(socket.assigns.text_nodes, version.id)
    )
  end

  def list_second_reader_text_nodes(_main_text_nodes, @internal_commentary_magic_string), do: []

  def list_second_reader_text_nodes(main_text_nodes, version_id) do
    start_location = List.first(main_text_nodes).location
    end_location = List.last(main_text_nodes).location

    TextNodes.get_text_nodes_by_version_between_locations(
      version_id,
      start_location,
      end_location
    )
    |> TextNodes.tag_text_nodes()
  end

  defp format_toc(version_id, top_level_location, second_level_location) do
    toc = Versions.get_table_of_contents(version_id)

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

  defp format_toc(version_id, top_level_location) do
    toc = Versions.get_table_of_contents(version_id)

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

  def handle_event("second-level-location-change", _, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "second-reader-change",
        %{"second_reader" => %{"second_reader_select" => version_id}},
        socket
      ) do
    text_nodes = list_second_reader_text_nodes(socket.assigns.text_nodes, version_id)

    {:noreply,
     socket
     |> assign(
       second_reader_text_nodes: text_nodes,
       second_reader_selection: version_id
     )}
  end

  def handle_event("top-level-location-change", %{"location" => location}, socket) do
    version = socket.assigns.version
    top_level = Map.get(location, "top_level_location") |> String.to_integer()

    {top_level_toc, second_level_toc} = format_toc(version.id, top_level, 1)

    {:noreply, socket |> assign(top_level_toc: top_level_toc, second_level_toc: second_level_toc)}
  end

  def handle_event("change-location", %{"location" => location}, socket) do
    top_level = Map.get(location, "top_level_location")
    second_level = Map.get(location, "second_level_location")
    version = socket.assigns.version
    location_s = "#{top_level}.#{second_level}.1"

    {:noreply, socket |> push_patch(to: "/versions/#{version.id}?location=#{location_s}")}
  end

  def handle_event(event, _, socket) do
    IO.puts("Failed to capture event #{event}")

    {:noreply, socket}
  end

  defp get_passage(version_id, passage_number) when is_binary(passage_number),
    do: get_passage(version_id, String.to_integer(passage_number))

  defp get_passage(version_id, passage_number) do
    passage = Versions.get_version_passage(version_id, passage_number)

    organize_passage(passage)
  end

  defp get_passage_by_location(version_id, location) when is_list(location) do
    passage = Versions.get_version_passage_by_location(version_id, location)

    organize_passage(passage)
  end

  defp organize_passage(passage) do
    elements =
      passage.text_nodes
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

    %{comments: comments, footnotes: footnotes, passage: passage}
  end

  defp page_title(:show), do: "Show Version"
  defp page_title(:edit), do: "Edit Version"

  defp internal_commentary_magic_string, do: @internal_commentary_magic_string
end
