defmodule TextServer.Exemplars do
  @moduledoc """
  The Exemplars context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Versions

  alias TextServer.ElementTypes
  alias TextServer.ExemplarJobRunner
  alias TextServer.Exemplars.Exemplar
  alias TextServer.Projects.Exemplar, as: ProjectExemplar
  alias TextServer.TextElements
  alias TextServer.TextNodes

  @location_regex ~r/\{\d+\.\d+\.\d+\}/

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

  def create_exemplar(attrs, work, project) do
    {:ok, exemplar} =
      Repo.transaction(fn ->
        {:ok, version} =
          Versions.find_or_create_version(
            attrs
            |> Map.take(["description", "urn"])
            |> Enum.into(%{
              "label" => Map.get(attrs, "title"),
              # FIXME: (charles) Eventually we'll want to be more
              # flexible on the version_type
              "version_type" => :commentary,
              "work_id" => work.id
            })
          )

        {:ok, exemplar} =
          %Exemplar{}
          |> Exemplar.changeset(attrs |> Map.put("version_id", version.id))
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

  def find_or_create_exemplar(attrs) do
    query = from(e in Exemplar, where: e.urn == ^attrs[:urn])

    case Repo.one(query) do
      nil -> create_exemplar(attrs)
      exemplar -> {:ok, exemplar}
    end
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

    result =
      if String.ends_with?(exemplar.filename, ".docx") do
        parse_exemplar_docx(exemplar)
      else
        parse_exemplar_xml(exemplar)
      end

    case result do
      {:ok, _} ->
        update_exemplar(exemplar, %{parsed_at: NaiveDateTime.utc_now()})

      {:error, error} ->
        IO.puts("There was an error parsing exemplar ##{exemplar.id}:")
        IO.inspect(error)
        {:error, error}
    end
  end

  def parse_exemplar_docx(%Exemplar{} = exemplar) do
    # `track_changes: "all"` catches comments; see example below
    {:ok, ast} = Panpipe.ast(input: exemplar.filename, track_changes: "all")
    fragments = Map.get(ast, :children, []) |> Enum.map(&collect_fragments/1)
    serialized_fragments = fragments |> Enum.map(&serialize_for_database/1)

    nodes =
      serialized_fragments
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
    # TODO: (charles) filter for locations first
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
        regex_list when is_list(regex_list) -> parse_location_marker(regex_list)
        _ -> maybe_location_fragment
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
        {elements ++
           [
             %{
               attributes: Map.get(comment, :attributes),
               content: Map.get(comment, :content, []) |> Enum.reduce("", &flatten_string/2),
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
        {:comment, _} -> nil
        {:note, _} -> nil
        {_k, v} -> Enum.reduce(v, "", &flatten_string/2)
        _ -> nil
      end

    "#{string}#{s}"
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

  def handle_fragment(%Panpipe.AST.Span{} = fragment),
    do:
      {:comment,
       %{
         attributes: collect_attributes(fragment),
         content: collect_fragments(fragment)
       }}

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
