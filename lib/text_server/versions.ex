defmodule TextServer.Versions do
  @moduledoc """
  The Versions context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.ElementTypes
  alias TextServer.Projects.Version, as: ProjectVersion
  alias TextServer.TextElements
  alias TextServer.TextNodes
  alias TextServer.TextNodes.TextNode
  alias TextServer.VersionJobRunner
  alias TextServer.Versions.Passage
  alias TextServer.Versions.Version
  alias TextServer.Works

  @location_regex ~r/\{\d+\.\d+\.\d+\}/

  # the @attribution_regex is a special case for matching
  # old comments by Greg Nagy ("GN") that have been
  # manually attributed. Normally, attribution will come
  # directly from a comment's XML.
  @attribution_regex ~r/\[\[GN\s(\d{4}\.\d{2}\.\d{2})\]\]/

  # Many of the XML files that we need to process have
  # multiple declarations at the top of the file.
  # Erlang is pretty strict about following the XML
  # spec, so it chokes on the multiple declarations.
  # We use this regex to remove them.
  @invalid_declarations_regex ~r/<\?xml-model.*\?>/su

  defmodule VersionPassage do
    defstruct [:version_id, :passage, :passage_number, :text_nodes, :total_passages]
  end

  @spec list_versions(keyword | map) :: Scrivener.Page.t()
  @doc """
  Returns the list of versions.

  ## Examples

      iex> list_versions()
      [%Version{}, ...]

  """
  def list_versions(params \\ [page: 1, page_size: 20]) do
    Version
    |> Repo.paginate(params)
  end

  @spec list_versions_except(list(integer()), keyword | map) :: Scrivener.Page.t()
  def list_versions_except(version_ids, pagination_params \\ []) do
    Version
    |> where([e], e.id not in ^version_ids)
    |> Repo.paginate(pagination_params)
  end

  def list_sibling_versions(version) do
    Version
    |> where([v], v.work_id == ^version.work_id)
    |> Repo.all()
  end

  @doc """
  Gets a single version.

  Raises `Ecto.NoResultsError` if the Version does not exist.

  ## Examples

      iex> get_version!(123)
      %Version{}

      iex> get_version!(456)
      ** (Ecto.NoResultsError)

  """
  def get_version!(id), do: Repo.get!(Version, id)

  def get_version_by_urn!(urn), do: Repo.get_by!(Version, urn: urn)

  @doc """
  Creates a version.

  ## Examples

      iex> create_version(%{field: value})
      {:ok, %Version{}}

      iex> create_version(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_version(attrs \\ %{}) do
    %Version{}
    |> Version.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_version(attrs \\ %{}) do
    urn = Map.get(attrs, :urn, Map.get(attrs, "urn"))
    query = from(v in Version, where: v.urn == ^urn)

    case Repo.one(query) do
      nil ->
        create_version(attrs)

      version ->
        {:ok, version}
    end
  end

  def upsert_version(attrs) do
    urn = Map.get(attrs, :urn, Map.get(attrs, "urn"))
    query = from(v in Version, where: v.urn == ^urn)

    case Repo.one(query) do
      nil -> create_version(attrs)
      version -> update_version(version, attrs)
    end
  end

  def create_version(attrs, project) do
    urn = make_version_urn(attrs, project)

    {:ok, version} =
      Repo.transaction(fn ->
        {:ok, version} =
          %Version{}
          |> Version.changeset(attrs |> Map.put("urn", urn))
          |> Repo.insert()

        {:ok, _project_version} =
          %ProjectVersion{}
          |> ProjectVersion.changeset(%{version_id: version.id, project_id: project.id})
          |> Repo.insert()

        version
      end)

    %{id: version.id}
    |> VersionJobRunner.new()
    |> Oban.insert()
  end

  defp make_version_urn(%{"title" => title, "work_id" => work_id} = _version_params, project) do
    work = Works.get_work!(work_id)
    "#{work.urn}.#{String.downcase(project.domain)}-#{Recase.to_kebab(title)}-en"
  end

  @doc """
  Updates a version.

  ## Examples

      iex> update_version(version, %{field: new_value})
      {:ok, %Version{}}

      iex> update_version(version, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_version(%Version{} = version, attrs) do
    version
    |> Version.changeset(attrs)
    |> Repo.update()
  end

  def create_passage(attrs) do
    {:ok, passage} =
      %Passage{}
      |> Passage.changeset(attrs)
      |> Repo.insert()

    {:ok, passage}
  end

  def get_version_passage(version_id, passage_number \\ 1) do
    total_passages = get_total_passages(version_id)

    n =
      if passage_number > total_passages do
        total_passages
      else
        passage_number
      end

    passage =
      Passage
      |> where([p], p.version_id == ^version_id and p.passage_number == ^n)
      |> Repo.one()

    if is_nil(passage) do
      version = get_version!(version_id)
      paginate_version(version.id)
      get_version_passage(version_id, passage_number)
    else
      text_nodes =
        TextNodes.get_text_nodes_by_version_between_locations(
          version_id,
          passage.start_location,
          passage.end_location
        )

      %VersionPassage{
        version_id: version_id,
        passage: passage,
        passage_number: passage.passage_number,
        text_nodes: text_nodes,
        total_passages: total_passages
      }
    end
  end

  def get_version_passage_by_location(version_id, location) when is_list(location) do
    passage =
      Passage
      |> where(
        [p],
        p.version_id == ^version_id and
          p.start_location <= ^location and
          p.end_location >= ^location
      )
      |> Repo.one()

    text_nodes =
      TextNodes.get_text_nodes_by_version_between_locations(
        version_id,
        passage.start_location,
        passage.end_location
      )

    %VersionPassage{
      version_id: version_id,
      passage: passage,
      passage_number: passage.passage_number,
      text_nodes: text_nodes,
      total_passages: get_total_passages(version_id)
    }
  end

  @doc """
  Returns the total number of passages for a given version.

  ## Examples
    iex> get_total_passages(1)
    20
  """

  def get_total_passages(version_id) do
    total_passages_query =
      from(
        p in Passage,
        where: p.version_id == ^version_id,
        select: max(p.passage_number)
      )

    Repo.one(total_passages_query)
  end

  @doc """
  Returns a table of contents represented by a(n unordered) map of maps.

  ## Examples
    iex> get_table_of_contents(1)
    %{7 => %{1 => [1, 2, 3], 4 => [1, 2], 2 => [1, 2, 3], ...}, ...}
  """

  def get_table_of_contents(version_id) do
    locations = TextNodes.list_locations_by_version_id(version_id)

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
  Groups an Version's TextNodes into Pages by location.
  Returns {:ok, total_passages} on success.
  """

  def paginate_version(version_id) do
    q =
      from(
        t in TextNode,
        where: t.version_id == ^version_id,
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

      create_passage(%{
        end_location: last_node.location,
        version_id: version_id,
        passage_number: i + 1,
        start_location: first_node.location
      })
    end)

    {:ok, length(keys)}
  end

  @doc """
  Deletes a version.

  ## Examples

      iex> delete_version(version)
      {:ok, %Version{}}

      iex> delete_version(version)
      {:error, %Ecto.Changeset{}}

  """
  def delete_version(%Version{} = version) do
    Repo.delete(version)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking version changes.

  ## Examples

      iex> change_version(version)
      %Ecto.Changeset{data: %Version{}}

  """
  def change_version(%Version{} = version, attrs \\ %{}) do
    Version.changeset(version, attrs)
  end

  def clear_text_nodes(%Version{} = version) do
    TextNodes.delete_text_nodes_by_version_id(version.id)
  end

  def parse_version(%Version{} = version) do
    clear_text_nodes(version)

    case Path.extname(version.filename) do
      ".docx" -> parse_version_docx(version)
      ".xml" -> parse_version_xml(version)
      _ -> raise Xml.ParseError, version.filename
    end

    update_version(version, %{parsed_at: NaiveDateTime.utc_now()})
  end

  def parse_version_docx(%Version{} = version) do
    # `track_changes: "all"` catches comments; see example below
    {:ok, ast} = Panpipe.ast(input: version.filename, track_changes: "all")
    fragments = Map.get(ast, :children, []) |> Enum.map(&collect_fragments/1)
    serialized_fragments = fragments |> Enum.map(&serialize_for_database/1)

    nodes =
      serialized_fragments
      |> Enum.filter(fn {_location, text, _elements} -> String.trim(text) != "" end)
      |> Enum.map(fn {location, text, elements} ->
        {:ok, text_node} =
          TextNodes.find_or_create_text_node(%{
            version_id: version.id,
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

  def parse_version_xml(%Version{} = version) do
    # it's unfortunate that we need to load the whole file into
    # memory to get rid of a few strings at the beginning ---
    # maybe we can sort out a workaround soon.
    file = File.read!(version.filename) |> String.replace(@invalid_declarations_regex, "")
    {:ok, version_data} = DataSchema.to_struct(file, Xml.Versions.Version)

    # text_node_schema =
    #   DataSchema.to_runtime_schema([
    #     has_many: {:text_nodes, version_data.cref_pattern, Xml.Versions.TextNodes.text_node_fields(version_data.cref_pattern)}
    #   ])
    ref_levels = version_data.structure |> Enum.reverse()
    crefs =
      version_data.cref_patterns
      |> Enum.map(fn pattern ->
        pattern
        |> String.replace("tei:", "")
        |> String.replace(~r/\[@n='\$[[:digit:]]+'\]/, "")
      end)

    body_fields = Enum.with_index()

    ## we could potentially nest everything, but then we're just re-creating
    # the XML structure
    body_fields = Enum.with_index(crefs) |> Enum.map(fn {xpath, index} ->
      name = Enum.at(ref_levels, index) |> String.to_atom()
      {:field, {name, "#{xpath}/@n", }}
    end)

    ## this doesn't work reliably because of unpredictable child nodes
    ## within each text node
    text_node_fields = [
      aggregate: {:location, body_fields, &{:ok, &1}},
      field: {:text, ".//text()", &{:ok, &1}}
    ]

    text_node_xpath = List.first(crefs)
    text_nodes_fields = [
      has_many: {:text_nodes, "/#{text_node_xpath}", {%{}, text_node_fields}}
    ]

    {:ok, text_nodes} = DataSchema.to_struct(file, %{}, text_nodes_fields, Xml.XPathAccessor)
    # if is_nil(elems) do
    #   IO.inspect("No text elements? #{inspect(body_data)}")
    #   []
    # else
    #   Enum.filter(elems, fn el -> Map.has_key?(el, :content) end)
    #   |> Enum.map(fn tn ->
    #     attrs = %{
    #       location: tn.location,
    #       text: tn.content,
    #       version_id: version.id
    #     }

    #     TextServer.TextNodes.create_text_node(attrs)
    #   end)

    #   Enum.filter(elems, fn el ->
    #     !Enum.all?([
    #       Map.has_key?(el, :content),
    #       Enum.member?(@excluded_element_types, el[:tag_name])
    #     ])
    #   end)
    #   |> Enum.map(fn el ->
    #     text_node = TextServer.TextNodes.get_by(%{location: el.location, version_id: version.id})

    #     unless is_nil(text_node) do
    #       {:ok, element_type} =
    #         TextServer.ElementTypes.find_or_create_element_type(%{
    #           name: el[:tag_name]
    #         })

    #       {:ok, _text_element} =
    #         TextServer.TextElements.find_or_create_text_element(
    #           el
    #           |> Map.delete(:type)
    #           |> Map.merge(%{
    #             element_type_id: element_type.id,
    #             end_text_node_id: text_node.id,
    #             start_text_node_id: text_node.id
    #           })
    #           |> Map.put_new(:attributes, %{})
    #           |> Map.put_new(:start_offset, el[:offset])
    #           |> Map.put_new(:end_offset, el[:offset])
    #         )
    #     end
    #   end)
    # end

    # {:ok, version}
  end
end
