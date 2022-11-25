defmodule TextServer.Exemplars do
  @moduledoc """
  The Exemplars context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Versions

  alias TextServer.ElementTypes
  alias TextServer.ExemplarJobRunner
  alias TextServer.Exemplars.Page
  alias TextServer.Exemplars.Exemplar
  alias TextServer.Projects.Exemplar, as: ProjectExemplar
  alias TextServer.TextElements
  alias TextServer.TextNodes
  alias TextServer.TextNodes.TextNode
  alias TextServer.Works

  @location_regex ~r/\{\d+\.\d+\.\d+\}/

  # the @attribution_regex is a special case for matching
  # old comments by Greg Nagy ("GN") that have been
  # manually attributed. Normally, attribution will come
  # directly from a comment's XML.
  @attribution_regex ~r/\[\[GN\s(\d{4}\.\d{2}\.\d{2})\]\]/

  defmodule ExemplarPage do
    defstruct [:exemplar_id, :page, :page_number, :text_nodes, :total_pages]
  end

  @doc """
  Returns the list of exemplars.

  ## Examples

      iex> list_exemplars()
      [%Exemplar{}, ...]

  """
  def list_exemplars do
    Repo.all(Exemplar)
  end

  @doc """
  Returns a list of exemplars that have not been added as
  ProjectExemplars in the given list of `exemplar_ids`.

  ## Examples

  		iex> list_exemplars_except([%ProjectExemplar{}, ...])
  		[%Exemplar{}, ...]
  """
  def list_exemplars_except(exemplar_ids, pagination_params \\ []) do
    Exemplar
    |> where([e], e.id not in ^exemplar_ids)
    |> Repo.paginate(pagination_params)
  end

  def get_exemplar_page(exemplar_id, page_number \\ 1) do
    total_pages = get_total_pages(exemplar_id)

    n =
      if page_number > total_pages do
        total_pages
      else
        page_number
      end

    page =
      Page
      |> where([p], p.exemplar_id == ^exemplar_id and p.page_number == ^n)
      |> Repo.one()

    if is_nil(page) do
      ex = get_exemplar!(exemplar_id)
      paginate_exemplar(ex)
      get_exemplar_page(exemplar_id, page_number)
    else
      text_nodes =
        TextNodes.get_text_nodes_by_exemplar_between_locations(
          exemplar_id,
          page.start_location,
          page.end_location
        )

      %ExemplarPage{
        exemplar_id: exemplar_id,
        page: page,
        page_number: page.page_number,
        text_nodes: text_nodes,
        total_pages: total_pages
      }
    end
  end

  def get_exemplar_page_by_location(exemplar_id, location) when is_list(location) do
    page =
      Page
      |> where(
        [p],
        p.exemplar_id == ^exemplar_id and
          p.start_location <= ^location and
          p.end_location >= ^location
      )
      |> Repo.one()

    text_nodes =
      TextNodes.get_text_nodes_by_exemplar_between_locations(
        exemplar_id,
        page.start_location,
        page.end_location
      )

    %ExemplarPage{
      exemplar_id: exemplar_id,
      page: page,
      page_number: page.page_number,
      text_nodes: text_nodes,
      total_pages: get_total_pages(exemplar_id)
    }
  end

  @doc """
  Returns the total number of pages for a given exemplar.

  ## Examples
    iex> get_total_pages(1)
    20
  """

  def get_total_pages(exemplar_id) do
    total_pages_query =
      from(
        p in Page,
        where: p.exemplar_id == ^exemplar_id,
        select: max(p.page_number)
      )

    Repo.one(total_pages_query)
  end

  @doc """
  Returns a table of contents represented by a(n unordered) map of maps.

  ## Examples
    iex> get_table_of_contents(1)
    %{7 => %{1 => [1, 2, 3], 4 => [1, 2], 2 => [1, 2, 3], ...}, ...}
  """

  def get_table_of_contents(exemplar_id) do
    locations = TextNodes.list_locations_by_exemplar_id(exemplar_id)

    locations |> Enum.reduce(%{}, &nest_location/2)
  end

  defp nest_location(l, acc) when length(l) == 3 do
    [x | rest] = l
    [y | z] = rest

    curr =
      case acc do
        %{^x => %{^y => value}} -> value
        _ -> []
      end

    put_in(acc, Enum.map([x, y], &Access.key(&1, %{})), curr ++ z)
  end

  defp nest_location(l, acc) when length(l) == 2 do
    [x | y] = l

    Map.update(acc, x, y, fn arr -> arr ++ y end)
  end

  defp nest_location(l, acc) when length(l) == 1 do
    acc
  end

  @doc """
  Groups an Exemplar's TextNodes into Pages by location.
  Returns {:ok, total_pages} on success.
  """

  def paginate_exemplar(exemplar) do
    q =
      from(
        t in TextNode,
        where: t.exemplar_id == ^exemplar.id,
        order_by: [asc: t.location]
      )

    text_nodes = Repo.all(q)

    grouped_text_nodes =
      text_nodes
      |> Enum.filter(fn tn -> tn.location != [0] end)
      |> Enum.group_by(fn tn ->
        location = tn.location

        if length(tn.location) > 1 do
          Enum.take(location, length(tn.location) - 1)
        else
          line = List.first(location)

          Integer.floor_div(line, 20)
        end
      end)

    keys = Map.keys(grouped_text_nodes) |> Enum.sort()

    keys
    |> Enum.with_index()
    |> Enum.each(fn {k, i} ->
      text_nodes = Map.get(grouped_text_nodes, k)
      first_node = List.first(text_nodes)
      last_node = List.last(text_nodes)

      create_page(%{
        end_location: last_node.location,
        exemplar_id: exemplar.id,
        page_number: i + 1,
        start_location: first_node.location
      })
    end)

    {:ok, length(keys)}
  end

  @doc """
  Gets a single exemplar.

  Raises `Ecto.NoResultsError` if the Exemplar does not exist.

  ## Examples

      iex> get_exemplar!(123)
      %Exemplar{}

      iex> get_exemplar!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exemplar!(id), do: Repo.get!(Exemplar, id)

  @doc """
  Creates an exemplar.

  ## Examples

      iex> create_exemplar(%{field: value})
      {:ok, %Exemplar{}}

      iex> create_exemplar(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exemplar(attrs) do
    {:ok, exemplar} =
      %Exemplar{}
      |> Exemplar.changeset(attrs)
      |> Repo.insert()

    {:ok, exemplar}
  end

  def create_exemplar(attrs, project) do
    urn = make_exemplar_urn(attrs, project)
    {:ok, exemplar} =
      Repo.transaction(fn ->
        {:ok, version} =
          Versions.find_or_create_version(
            attrs
            |> Map.take(["description", "work_id"])
            |> Enum.into(%{
              "label" => Map.get(attrs, "title"),
              # FIXME: (charles) Eventually we'll want to be more
              # flexible on the version_type
              "urn" => urn,
              "version_type" => :commentary
            })
          )

        {:ok, exemplar} =
          %Exemplar{}
          |> Exemplar.changeset(attrs |> Map.put("version_id", version.id) |> Map.put("urn", urn))
          |> Repo.insert()

        {:ok, _project_exemplar} =
          %ProjectExemplar{}
          |> ProjectExemplar.changeset(%{exemplar_id: exemplar.id, project_id: project.id})
          |> Repo.insert()

        exemplar
      end)

    %{id: exemplar.id}
    |> ExemplarJobRunner.new()
    |> Oban.insert()
  end

  defp make_exemplar_urn(%{"title" => title, "work_id" => work_id} = _exemplar_params, project) do
    work = Works.get_work!(work_id)
    "#{work.urn}:#{String.downcase(project.domain)}.#{Recase.to_kebab(title)}-en"
  end

  def find_or_create_exemplar(attrs) do
    query = from(e in Exemplar, where: e.urn == ^attrs[:urn])

    case Repo.one(query) do
      nil -> create_exemplar(attrs)
      exemplar -> {:ok, exemplar}
    end
  end

  def create_page(attrs) do
    {:ok, page} =
      %Page{}
      |> Page.changeset(attrs)
      |> Repo.insert()

    {:ok, page}
  end

  @doc """
  Updates an exemplar.

  ## Examples

      iex> update_exemplar(exemplar, %{field: new_value})
      {:ok, %Exemplar{}}

      iex> update_exemplar(exemplar, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exemplar(%Exemplar{} = exemplar, attrs) do
    exemplar
    |> Exemplar.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an exemplar.

  ## Examples

      iex> delete_exemplar(exemplar)
      {:ok, %Exemplar{}}

      iex> delete_exemplar(exemplar)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exemplar(%Exemplar{} = exemplar) do
    Repo.delete(exemplar)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exemplar changes.

  ## Examples

      iex> change_exemplar(exemplar)
      %Ecto.Changeset{data: %Exemplar{}}

  """
  def change_exemplar(%Exemplar{} = exemplar, attrs \\ %{}) do
    Exemplar.changeset(exemplar, attrs)
  end

  def clear_text_nodes(%Exemplar{} = exemplar) do
    TextNodes.delete_text_nodes_by_exemplar_id(exemplar.id)
  end

  def parse_exemplar(%Exemplar{} = exemplar) do
    clear_text_nodes(exemplar)

    _result =
      if String.ends_with?(exemplar.filename, ".docx") do
        parse_exemplar_docx(exemplar)
      else
        parse_exemplar_xml(exemplar)
      end

    update_exemplar(exemplar, %{parsed_at: NaiveDateTime.utc_now()})
  end

  def parse_exemplar_docx(%Exemplar{} = exemplar) do
    # `track_changes: "all"` catches comments; see example below
    {:ok, ast} = Panpipe.ast(input: exemplar.filename, track_changes: "all")
    fragments = Map.get(ast, :children, []) |> Enum.map(&collect_fragments/1)
    serialized_fragments = fragments |> Enum.map(&serialize_for_database/1)

    nodes =
      serialized_fragments
      |> Enum.filter(fn {_location, text, _elements} -> String.trim(text) != "" end)
      |> Enum.map(fn {location, text, elements} ->
        {:ok, text_node} =
          TextNodes.find_or_create_text_node(%{
            exemplar_id: exemplar.id,
            location: location,
            text: text
          })

        elements
        |> Enum.map(fn el ->
          {:ok, element_type} =
            ElementTypes.find_or_create_element_type(%{name: Atom.to_string(el[:type])})

          {:ok, text_element} =
            TextElements.find_or_create_text_element(
              el
              |> Map.delete(:type)
              |> Map.merge(%{
                element_type_id: element_type.id,
                end_text_node_id: text_node.id,
                start_text_node_id: text_node.id
              })
              |> Map.put_new(:attributes, %{})
              |> Map.put_new(:end_offset, el[:start_offset])
            )

          {:ok, {element_type, text_element}}
        end)

        {:ok, text_node}
      end)

    {:ok, nodes}
  end

  def serialize_for_database(list) do
    [location | list] = set_location(list)
    text = list |> Enum.reduce("", &flatten_string/2) |> String.trim_leading()

    # if getting the location has left the node starting with a single space,
    # pop that element off the node entirely. This helps to avoid off-by-one
    # errors in offsets. An assumption is made that a node that begins with
    # more than a single space character does so for a reason, so we maintain
    # that string
    list =
      if List.first(list) == {:string, " "} do
        tl(list)
      else
        list
      end

    {text_elements, _final_offset} = list |> Enum.reduce({[], 0}, &tag_elements/2)

    {location, text, text_elements}
  end

  def set_location(list) do
    [maybe_location_fragment | rest] = list

    maybe_location_string = get_maybe_location_string(maybe_location_fragment) || ""

    location =
      case Regex.run(@location_regex, maybe_location_string) do
        regex_list when is_list(regex_list) ->
          parse_location_marker(regex_list)

        nil ->
          [0]
          # _ -> maybe_location_fragment
      end

    [location | rest]
  end

  def get_maybe_location_string(fragment) do
    case fragment do
      [string: string] ->
        string

      {:string, string} ->
        string

      {_, maybe_list} when is_list(maybe_list) ->
        maybe_list |> Enum.find_value(&get_maybe_location_string/1)

      _ ->
        false
    end
  end

  defp parse_location_marker(regex_list) do
    List.first(regex_list)
    |> String.replace("{", "")
    |> String.replace("}", "")
    |> String.split(".")
    |> Enum.map(&String.to_integer/1)
  end

  def tag_elements(fragment, {elements, offset}) do
    case fragment do
      [string: text] ->
        {elements, offset + String.length(text)}

      {:string, text} ->
        {elements, offset + String.length(text)}

      {:comment, comment} ->
        content =
          Map.get(comment, :content, [])
          |> Enum.reduce("", &flatten_string/2)

        attributes = get_comment_attributes(comment, content)

        {elements ++
           [
             %{
               attributes: attributes,
               content:
                 content
                 |> String.replace(@attribution_regex, "")
                 |> String.trim_leading(),
               end_offset: offset,
               start_offset: offset,
               type: :comment
             }
           ], offset}

      {:emph, emph} ->
        s = emph |> Enum.reduce("", &flatten_string/2)
        end_offset = offset + String.length(s)

        {elements ++
           [
             %{
               content: s,
               end_offset: end_offset,
               start_offset: offset,
               type: :emph
             }
           ], end_offset}

      {:note, note} ->
        {elements ++
           [
             %{
               content: note |> Enum.reduce("", &flatten_string/2),
               start_offset: offset,
               type: :note
             }
           ], offset}

      {:strong, strong} ->
        s = strong |> Enum.reduce("", &flatten_string/2)
        end_offset = offset + String.length(s)

        {elements ++
           [
             %{
               content: s,
               end_offset: end_offset,
               start_offset: offset,
               type: :strong
             }
           ], end_offset}

      {:underline, underline} ->
        s = underline |> Enum.reduce("", &flatten_string/2)
        end_offset = offset + String.length(s)

        {elements ++
           [
             %{
               content: s,
               end_offset: end_offset,
               start_offset: offset,
               type: :underline
             }
           ], end_offset}

      _ ->
        {elements, offset}
    end
  end

  def flatten_string(fragment, string \\ "") do
    s =
      case fragment do
        [string: text] -> text
        {:string, text} -> text
        {:note, _} -> nil
        {:comment, _} -> nil
        {:change, _} -> nil
        {:span, _} -> nil
        {_k, v} -> Enum.reduce(v, "", &flatten_string/2)
        _ -> nil
      end

    "#{string}#{s}"
  end

  def get_comment_attributes(comment, s) do
    attrs = Map.get(comment, :attributes)

    if match = Regex.run(@attribution_regex, s) do
      date_string = Enum.fetch!(match, 1) |> String.replace(".", "-")
      {:ok, date_time, _} = DateTime.from_iso8601(date_string <> "T00:00:00Z")

      kv_pairs =
        Map.get(attrs, :key_value_pairs, %{})
        |> Map.put("author", "Gregory Nagy")
        |> Map.put("date", date_time)

      Map.put(attrs, :key_value_pairs, kv_pairs)
    else
      attrs
    end
  end

  def collect_attributes(node) do
    node |> Map.get(:attr, %{}) |> Map.take([:classes, :key_value_pairs])
  end

  def collect_fragments(node),
    do: collect_fragments(node, :children)

  def collect_fragments(node, attr) do
    Map.get(node, attr, []) |> Enum.map(fn n -> handle_fragment(n) end) |> List.flatten()
  end

  def handle_fragment(%Panpipe.AST.Emph{} = fragment),
    do: {:emph, collect_fragments(fragment)}

  def handle_fragment(%Panpipe.AST.Note{} = fragment),
    do: {:note, collect_fragments(fragment)}

  def handle_fragment(%Panpipe.AST.Para{} = fragment),
    do: collect_fragments(fragment)

  def handle_fragment(%Panpipe.AST.Str{} = fragment),
    do: {:string, Map.get(fragment, :string, "")}

  def handle_fragment(%Panpipe.AST.Space{} = _fragment),
    do: {:string, " "}

  def handle_fragment(%Panpipe.AST.Span{} = fragment) do
    attributes = collect_attributes(fragment)
    classes = Map.get(attributes, :classes, [])

    fragment_type =
      cond do
        Enum.member?(classes, "deletion") -> :change
        Enum.member?(classes, "insertion") -> :change
        Enum.member?(classes, "paragraph-deletion") -> :change
        Enum.member?(classes, "paragraph-insertion") -> :change
        Enum.member?(classes, "comment-end") -> :comment
        Enum.member?(classes, "comment-start") -> :comment
        true -> :span
      end

    {fragment_type,
     %{
       attributes: attributes,
       content: collect_fragments(fragment)
     }}
  end

  def handle_fragment(%Panpipe.AST.Strong{} = fragment),
    do: {:strong, collect_fragments(fragment)}

  def handle_fragment(%Panpipe.AST.Underline{} = fragment),
    do: {:underline, collect_fragments(fragment)}

  def handle_fragment(fragment) do
    name =
      fragment.__struct__
      |> Module.split()
      |> List.last()
      |> String.downcase()
      |> String.to_atom()

    {name, collect_fragments(fragment)}
  end

  defp parse_exemplar_xml(%Exemplar{} = exemplar) do
    {:ok, exemplar}
  end
end
