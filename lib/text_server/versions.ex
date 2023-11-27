defmodule TextServer.Versions do
  @moduledoc """
  The Versions context.
  """

  import Ecto.Query, warn: false

  require Logger

  alias Ecto

  alias TextServer.Repo

  alias TextServer.Languages
  alias TextServer.Projects.Version, as: ProjectVersion
  alias TextServer.TextElements
  alias TextServer.TextNodes
  alias TextServer.TextNodes.TextNode
  alias TextServer.Versions.Passage
  alias TextServer.Versions.Version
  alias TextServer.Versions.XmlDocuments.XmlDocument
  alias TextServer.Works
  alias TextServer.Works.Work

  @location_regex ~r/\{\d+\.\d+\.\d+\}/

  # the @attribution_regex is a special case for matching
  # old comments by Greg Nagy ("GN") that have been
  # manually attributed. Normally, attribution will come
  # directly from a comment's XML.
  @attribution_regex ~r/\[\[GN\s(\d{4}\.\d{2}\.\d{2})\]\]/

  defmodule VersionPassage do
    defstruct [:version_id, :passage, :passage_number, :text_nodes, :total_passages]
  end

  def create_commentary(work, version_data) do
    create_version(work, version_data, :commentary)
  end

  def create_edition(work, version_data) do
    create_version(work, version_data, :edition)
  end

  def create_translation(work, version_data) do
    create_version(work, version_data, :translation)
  end

  def create_version(work, version_data, version_type) do
    urn = Map.get(version_data, :urn) |> CTS.URN.parse()
    file = get_version_file(urn)
    xml_raw = File.read!(file)
    md5 = :crypto.hash(:md5, xml_raw) |> Base.encode16(case: :lower)
    language = Languages.get_language_by_iso_code!(version_data.language)

    {:ok, version} =
      Map.take(version_data, [:description, :label])
      |> Map.merge(%{
        filename: file,
        filemd5hash: md5,
        language_id: language.id,
        urn: urn,
        version_type: version_type,
        work_id: work.id
      })
      |> find_or_create_version()

    create_xml_document!(version, %{document: xml_raw})
  end

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

  def create_version!(attrs \\ %{}) do
    %Version{}
    |> Version.changeset(attrs)
    |> Repo.insert!()
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

  @doc """
  This create_version/2 is for creating a version from a docx file.
  """
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
    |> TextServer.Workers.VersionWorker.new()
    |> Oban.insert()
  end

  def create_versions_of_work(%Work{} = work) do
    {:ok, work_cts_data} = Works.get_work_cts_data(work)

    Map.get(work_cts_data, :commentaries) |> Enum.each(&create_commentary(work, &1))
    Map.get(work_cts_data, :editions) |> Enum.each(&create_edition(work, &1))
    Map.get(work_cts_data, :translations) |> Enum.each(&create_translation(work, &1))
  end

  def get_version_file(urn) do
    path = CTS.base_cts_dir() <> "/" <> Works.get_work_dir(urn) <> "/#{urn.work_component}.xml"

    if File.exists?(path) do
      path
    else
      :enoent
    end
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
    |> where([v], v.work_id == ^version.work_id and v.id != ^version.id)
    |> Repo.all()
  end

  def list_versions_for_urn(%CTS.URN{} = urn, opts \\ []) do
    from(v in Version,
      where:
        fragment("? ->> ? = ?", v.urn, "namespace", ^urn.namespace) and
          fragment("? ->> ? = ?", v.urn, "text_group", ^urn.text_group) and
          fragment("? ->> ? = ?", v.urn, "work", ^urn.work)
    )
    |> Repo.all(opts)
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
  def get_version!(id), do: Repo.get!(Version, id) |> Repo.preload(:language)

  def get_version_by_urn!(urn) when is_binary(urn) do
    get_version_by_urn!(CTS.URN.parse(urn))
  end

  def get_version_by_urn!(%CTS.URN{} = urn) do
    version = get_version_by_urn(urn)

    if is_nil(version) do
      raise "No version found for urn #{urn}"
    else
      version
    end
  end

  def get_version_by_urn(%CTS.URN{} = urn) do
    version_urn_s = "#{urn.prefix}:#{urn.protocol}:#{urn.namespace}:#{urn.work_component}"
    Repo.get_by(Version, urn: version_urn_s)
  end

  defp make_version_urn(version_params, project) do
    work_id = Map.fetch!(version_params, "work_id")
    label = Map.fetch!(version_params, "label")
    work = Works.get_work!(work_id)
    "#{work.urn}.#{String.downcase(project.domain)}-#{Recase.to_kebab(label)}-en"
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

  def get_passage_by_urn(urn) do
    try do
      version = get_version_by_urn!(urn)
      {:ok, list_version_text_nodes(version, CTS.URN.parse(urn).passage_component)}
    rescue
      e ->
        Logger.error(Exception.format(:error, e, __STACKTRACE__))
        {:error, e}
    end
  end

  def list_version_text_nodes(%Version{} = version, passages) when is_nil(passages) do
    cardinality =
      TextNode
      |> where([t], t.version_id == ^version.id)
      |> select(fragment("max(cardinality(location))"))
      |> Repo.one()

    start_location = List.duplicate(1, cardinality)
    TextNodes.list_text_nodes_by_version_from_start_location(version, start_location)
  end

  def list_version_text_nodes(%Version{} = version, passage_s) when is_binary(passage_s) do
    list_version_text_nodes(version, String.split(passage_s, "-"))
  end

  def list_version_text_nodes(%Version{} = version, passages) when length(passages) == 1 do
    start_location = List.first(passages) |> String.split(".") |> Enum.map(&String.to_integer/1)
    TextNodes.list_text_nodes_by_version_from_start_location(version, start_location)
  end

  def list_version_text_nodes(%Version{} = version, passages) when length(passages) == 2 do
    start_location = List.first(passages) |> String.split(".") |> Enum.map(&String.to_integer/1)
    TextNodes.list_text_nodes_from_location(version, start_location)
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

      case paginate_version(version.id) do
        {:ok, _} -> get_version_passage(version_id, passage_number)
        {:error, message} -> raise message
      end
    else
      text_nodes =
        TextNodes.list_text_nodes_from_location(
          %Version{id: version_id},
          passage.start_location
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
    case Passage
         |> where(
           [p],
           p.version_id == ^version_id and
             p.start_location <= ^location and
             p.end_location >= ^location
         )
         |> Repo.one() do
      nil ->
        Logger.warning("No text_nodes found.")
        nil

      passage ->
        text_nodes =
          TextNodes.list_text_nodes_from_location(
            %Version{id: version_id},
            passage.start_location
          )

        %VersionPassage{
          version_id: version_id,
          passage: passage,
          passage_number: passage.passage_number,
          text_nodes: text_nodes,
          total_passages: get_total_passages(version_id)
        }
    end
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
        order_by: [asc: t.n]
      )

    text_nodes = Repo.all(q)
    group_and_paginate_text_nodes(version_id, text_nodes)
  end

  defp group_and_paginate_text_nodes(version_id, text_nodes) when length(text_nodes) == 0 do
    {:error, "No text nodes found for version #{version_id}."}
  end

  defp group_and_paginate_text_nodes(version_id, text_nodes) do
    chunked_text_nodes =
      text_nodes
      |> Enum.chunk_every(50)

    chunked_text_nodes
    |> Enum.with_index()
    |> Enum.each(fn {chunk, i} ->
      first_node = List.first(chunk)
      last_node = List.last(chunk)

      create_passage(%{
        end_location: last_node.location,
        version_id: version_id,
        passage_number: i + 1,
        start_location: first_node.location
      })
    end)

    {:ok, length(chunked_text_nodes)}
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

  def create_xml_document!(%Version{} = version, attrs \\ %{}) do
    version
    |> Ecto.build_assoc(:xml_document)
    |> XmlDocument.changeset(attrs)
    |> Repo.insert!()
  end

  # Processing functions begin here

  def clear_text_nodes(%Version{} = version) do
    TextNodes.delete_text_nodes_by_version_id(version.id)
  end

  def parse_version(%Version{} = version) do
    clear_text_nodes(version)

    case Path.extname(version.filename) do
      ".docx" -> parse_version_docx(version)
      ".xml" -> queue_version_for_external_parsing(version)
      _ -> raise "Unable to parse version #{version.filename}"
    end

    update_version(version, %{parsed_at: NaiveDateTime.utc_now()})
  end

  def queue_version_for_external_parsing(version) do
    {:ok, chan} = AMQP.Application.get_channel(:cts_xml_parser)

    AMQP.Basic.publish(
      chan,
      "",
      Application.get_env(:amqp, :queue),
      to_string(version.id)
    )
  end

  # pandoc: /app/data/user_uploads/exemplar_files/GN_A Pausanias reader in progress, restarted 2020.05.01(1)-Gipson-6-18-2022.docx
  def parse_version_docx(%Version{} = version) do
    # `track_changes: "all"` catches comments; see example below
    {:ok, ast} =
      Panpipe.ast(
        input: version.filename,
        extract_media: version.urn,
        track_changes: "all"
      )

    # We should be able to transform the AST into a collection
    # of text nodes, even when we have paragraphs (like
    # poetry or bulleted lists) that break our assumptions about
    # how to locate elements.
    # Why not use the AST transformation to tag locations, as well as:
    # - TODO: join "orphaned" nodes to the previously seen location
    #   - could we use ETS for this? https://elixir-lang.org/getting-started/mix-otp/ets.html
    # - TODO: convert to markdown with locations stored in text_nodes

    fragments = collect_fragments(ast)
    # we need to keep track of location fragments that have been seen and use
    # the last-seen fragment in cases where the location gets zeroed out
    {_last_loc, located_fragments} =
      fragments
      |> Enum.reduce({[0], %{}}, &set_locations/2)

    joined_fragments =
      located_fragments
      |> Enum.map(fn {location, fragments} ->
        serialize_fragments(location, fragments)
      end)

    nodes =
      joined_fragments
      |> Enum.filter(fn {_location, text, _els} -> String.trim(text) != "" end)
      |> Enum.map(fn {location, text, elements} ->
        {:ok, text_node} =
          TextNodes.find_or_create_text_node(%{
            version_id: version.id,
            location: location,
            text: text,
            urn: "#{version.urn}:#{Enum.join(location, ".")}"
          })

        _elements_and_errors = TextElements.find_or_create_text_elements(text_node, elements)

        {:ok, text_node}
      end)

    {:ok, nodes}
  end

  def set_locations({:paragraph, fragments}, state) do
    {loc, located_fragments} = set_locations(fragments, state)
    # So far, it seems to work well to treat paragraphs
    # as simply two newlines, like in Markdown.
    {loc,
     Map.update(located_fragments, loc, [], fn v ->
       # Don't add a paragraph break at the beginning of a
       # TextNode
       if Enum.empty?(v) do
         v
       else
         v ++ [{:string, "\n\n"}]
       end
     end)}
  end

  def set_locations(fragments, {prev_location, grouped_frags}) do
    [loc | frags] = set_location(prev_location, fragments)

    current_fragments = Map.get(grouped_frags, loc, [])

    # As far as I can tell, the call to List.flatten/1, although
    # it seems redundant, is necessary to esnure that we can
    # concatenate the lists successfully.
    updated_frags = current_fragments ++ List.flatten([frags])

    {loc, Map.put(grouped_frags, loc, updated_frags)}
  end

  def set_location(prev_location, list) when is_list(list) do
    [maybe_location_fragment | rest] = list

    maybe_location_string = get_maybe_location_string(maybe_location_fragment) || ""

    location =
      case Regex.run(@location_regex, maybe_location_string) do
        regex_list when is_list(regex_list) ->
          parse_location_marker(regex_list)

        nil ->
          [0]
      end

    if prev_location != [0] and location == [0] do
      # note that we return the entire list here so we don't
      # accidentally pop off important elements
      [prev_location | list]
    else
      [location | rest]
    end
  end

  # FIXME: This is a cludge for handling bulleted lists -- it won't
  # end up displaying the lists correctly.
  def set_location(prev_location, non_list) do
    [prev_location | [flatten_string(non_list)]]
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

  @doc """
  FIXME: (charles) There are some bugs with this approach,
  and it's a bit suboptimal for the ways that it reinvents
  the wheel.

  Bugs:
  - bullet_lists are not handled properly
  - poetry is not handled properly

  For examples, see especially Pausanias 5.10
  """
  def serialize_fragments(location, fragments) do
    text = fragments |> Enum.reduce("", &flatten_string/2)

    # if getting the location has left the node starting with a single space,
    # pop that element off the node entirely. This helps to avoid off-by-one
    # errors in offsets. An assumption is made that a node that begins with
    # more than a single space character does so for a reason, so we maintain
    # that string
    fragments =
      if List.first(fragments) == {:string, " "} do
        tl(fragments)
      else
        fragments
      end

    # Rather than using numeric offsets, why not pass in the urn and location,
    # building a URN with a subreference to the token(s) to which the element
    # is applied?
    {text_elements, _final_offset} = fragments |> Enum.reduce({[], 0}, &tag_elements/2)

    {location, text, text_elements}
  end

  def flatten_string(fragment, string \\ "") do
    s =
      case fragment do
        [string: text] -> text
        {:string, text} -> text
        {:link, fragments, _url} -> Enum.reduce(fragments, "", &flatten_string/2)
        {:note, _} -> nil
        {:comment, _} -> nil
        {:change, _} -> nil
        {:image, _} -> nil
        {:span, _} -> nil
        {_k, v} when not is_binary(v) -> Enum.reduce(v, "", &flatten_string/2)
        _ -> nil
      end

    "#{string}#{s}"
  end

  def tag_elements([string: text], {elements, offset}) do
    {elements, offset + String.length(text)}
  end

  def tag_elements({:string, text}, {elements, offset}) do
    {elements, offset + String.length(text)}
  end

  def tag_elements({:comment, comment}, {elements, offset}) do
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
  end

  def tag_elements({:emph, emph}, {elements, offset}) do
    s = emph |> Enum.reduce("", &flatten_string/2)
    end_offset = offset + String.length(s)

    # token = String.slice(s, offset..end_offset)

    # THIS COULD HAVE ALL BEEN SO MUCH SIMPLER?
    IO.puts("token: #{s}")

    {elements ++
       [
         %{
           content: s,
           end_offset: end_offset,
           start_offset: offset,
           type: :emph
         }
       ], end_offset}
  end

  def tag_elements({:image, image}, {elements, offset}) do
    s = image |> Enum.reduce("", &flatten_string/2)
    end_offset = offset + String.length(s)

    {elements ++
       [
         Map.merge(image, %{
           end_offset: end_offset,
           start_offset: offset,
           type: :image
         })
       ], end_offset}
  end

  def tag_elements({:link, link, url}, {elements, offset}) do
    s = link |> Enum.reduce("", &flatten_string/2)
    end_offset = offset + String.length(s)

    token = String.slice(s, offset..end_offset)

    IO.puts("token: #{token}")

    {elements ++
       [
         %{
           content: url,
           end_offset: end_offset,
           start_offset: offset,
           type: :link
         }
       ], end_offset}
  end

  def tag_elements({:note, note}, {elements, offset}) do
    {elements ++
       [
         %{
           content: note |> Enum.reduce("", &flatten_string/2),
           start_offset: offset,
           type: :note
         }
       ], offset}
  end

  def tag_elements({:strong, strong}, {elements, offset}) do
    s = strong |> Enum.reduce("", &flatten_string/2)
    end_offset = offset + String.length(s)

    token = String.slice(s, offset..end_offset)

    IO.puts("token: #{token}")

    {elements ++
       [
         %{
           content: s,
           end_offset: end_offset,
           start_offset: offset,
           type: :strong
         }
       ], end_offset}
  end

  def tag_elements({:superscript, superscript}, {elements, offset}) do
    s = superscript |> Enum.reduce("", &flatten_string/2)
    end_offset = offset + String.length(s)

    token = String.slice(s, offset..end_offset)

    IO.puts("token: #{token}")

    {elements ++
       [
         %{
           content: s,
           end_offset: end_offset,
           start_offset: offset,
           type: :superscript
         }
       ], end_offset}
  end

  def tag_elements({:underline, underline}, {elements, offset}) do
    s = underline |> Enum.reduce("", &flatten_string/2)
    end_offset = offset + String.length(s)

    token = String.slice(s, offset..end_offset)

    IO.puts("token: #{token}")

    {elements ++
       [
         %{
           content: s,
           end_offset: end_offset,
           start_offset: offset,
           type: :underline
         }
       ], end_offset}
  end

  def tag_elements(fragment, {elements, offset}) do
    Logger.info("Unused fragment when parsing document: #{inspect(fragment)}")

    {elements, offset}
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
    Map.get(node, attr, []) |> Enum.map(&handle_fragment/1) |> List.flatten()
  end

  def handle_fragment(%Panpipe.AST.BulletList{} = fragment) do
    {:bullet_list, %{content: collect_fragments(fragment)}}
  end

  def handle_fragment(%Panpipe.AST.Emph{} = fragment),
    do: {:emph, collect_fragments(fragment)}

  def handle_fragment(%Panpipe.AST.Image{} = fragment) do
    {:image, %{content: Map.fetch!(fragment, :target), attributes: collect_attributes(fragment)}}
  end

  def handle_fragment(%Panpipe.AST.Link{} = fragment) do
    {:link, collect_fragments(fragment), Map.fetch!(fragment, :target)}
  end

  def handle_fragment(%Panpipe.AST.Note{} = fragment),
    do: {:note, collect_fragments(fragment)}

  def handle_fragment(%Panpipe.AST.Para{} = fragment) do
    {:paragraph, collect_fragments(fragment)}
  end

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
end
