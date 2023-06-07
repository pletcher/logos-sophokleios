defmodule TextServerWeb.VersionLive.Show do
  use TextServerWeb, :live_view

  alias TextServerWeb.Components

  alias TextServer.TextNodes
  alias TextServer.Versions

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

    passage_page = get_passage_by_location(id, location)

    if is_nil(passage_page) do
      {:noreply, socket |> put_flash(:error, "No text nodes found for the given passage.")}
    else
      create_response(socket, id, passage_page)
    end
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

    version = Versions.get_version!(version_id)

    sibling_versions =
      Versions.list_sibling_versions(version)
      |> Enum.map(fn v ->
        [key: v.label, value: Integer.to_string(v.id), selected: version.id == v.id]
      end)

    text_nodes = passage.text_nodes
    location = List.first(text_nodes).location
    top_level_location = List.first(location)
    second_level_location = Enum.at(location, 1)
    toc = Versions.get_table_of_contents(version_id)

    {top_level_toc, second_level_toc} =
      if length(location) > 2 do
        format_toc(toc, top_level_location, second_level_location)
      else
        format_toc(toc, top_level_location)
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
       page_title: version.label,
       versions: sibling_versions,
       text_nodes: text_nodes |> TextNodes.tag_text_nodes(),
       top_level_location: top_level_location,
       top_level_toc: top_level_toc,
       second_level_location: second_level_location,
       second_level_toc: second_level_toc,
       version: version
     )}
  end

  def format_toc(toc, top_level_location, second_level_location) do
    {format_top_level_toc(toc, top_level_location),
     format_second_level_toc(toc, top_level_location, second_level_location)}
  end

  def format_toc(toc, top_level_location) do
    {format_top_level_toc(toc, top_level_location), nil}
  end

  @spec format_second_level_toc(map(), pos_integer(), pos_integer()) :: [
          [key: String.t(), value: String.t(), selected: boolean()]
        ]
  def format_second_level_toc(toc, top_level_location, location \\ 1) do
    Map.get(toc, top_level_location)
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(&[key: "Chapter #{&1}", value: &1, selected: &1 == location])
  end

  @spec format_top_level_toc(map(), pos_integer()) :: [
          [key: String.t(), value: String.t(), selected: boolean()]
        ]
  def format_top_level_toc(toc, location \\ 1) do
    Map.keys(toc)
    |> Enum.sort()
    |> Enum.map(&[key: "Book #{&1}", value: &1, selected: &1 == location])
  end

  @impl true
  def handle_event("highlight-comments", %{"comments" => comment_ids}, socket) do
    ids =
      comment_ids
      |> Jason.decode!()
      |> Enum.map(&String.to_integer/1)

    {:noreply, socket |> assign(highlighted_comments: ids)}
  end

  def handle_event("location-change", %{"location" => location} = _params, socket) do
    version_id = Map.get(location, "version_select")
    top_level = Map.get(location, "top_level_location") |> String.to_integer()
    second_level = Map.get(location, "second_level_location") |> String.to_integer()

    toc = Versions.get_table_of_contents(version_id)

    top_level_toc = format_top_level_toc(toc, top_level)
    second_level_toc = format_second_level_toc(toc, top_level, second_level)

    versions =
      socket.assigns.versions
      |> Enum.map(fn v ->
        id = Keyword.get(v, :value)
        Keyword.merge(v, selected: id == version_id)
      end)

    {:noreply,
     socket
     |> assign(
       second_level_toc: second_level_toc,
       versions: versions,
       top_level_toc: top_level_toc
     )}
  end

  def handle_event("change-location", %{"location" => location}, socket) do
    top_level = Map.get(location, "top_level_location")
    second_level = Map.get(location, "second_level_location")
    version_id = Map.get(location, "version_select", socket.assigns.version.id)
    location_s = "#{top_level}.#{second_level}.1"

    {:noreply, socket |> push_patch(to: "/versions/#{version_id}?location=#{location_s}")}
  end

  def handle_event(event, params, socket) do
    IO.puts("Failed to capture event #{event}")
    IO.inspect(params)

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

  defp organize_passage(passage) when is_nil(passage), do: nil

  defp organize_passage(passage) do
    elements =
      passage.text_nodes
      |> Enum.map(fn tn -> tn.text_elements end)
      |> List.flatten()

    comments =
      elements
      |> Enum.filter(fn te ->
        te.element_type.name == "comment" && !is_nil(te.content)
      end)
      |> Enum.map(fn c ->
        Map.merge(c, %{
          author: c.text_element_users |> Enum.map(& &1.email) |> Enum.join(", "),
          date: c.updated_at
        })
      end)

    footnotes =
      elements
      |> Enum.filter(fn te -> te.element_type.name == "note" end)

    %{comments: comments, footnotes: footnotes, passage: passage}
  end
end
