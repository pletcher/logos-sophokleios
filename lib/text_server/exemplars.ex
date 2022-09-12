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

  def parse_exemplar(%Exemplar{} = exemplar) do
    if String.ends_with?(exemplar.filename, ".docx") do
      parse_exemplar_docx(exemplar)
    else
      parse_exemplar_xml(exemplar)
    end
  end

  def process_exemplar_text_elements(exemplar, data) do
    data
    |> Enum.group_by(fn el -> el[:tag_name] end)
    |> Enum.each(fn {_k, v} ->
      [starts, ends] =
        case Enum.group_by(v, fn x -> Map.has_key?(x, :start) end) do
          %{true: starts, false: ends} -> [starts, ends]
          %{true: starts} -> [starts, []]
          %{false: ends} -> [[], ends]
        end

      indexed_starts = Enum.with_index(starts)

      indexed_starts
      |> Enum.each(fn {start, i} ->
        matching_end =
          case Enum.fetch(ends, i) do
            {:ok, e} ->
              e

            :error ->
              IO.inspect(
                "No matching end node found! Index: #{i}\n#{inspect(start)}\nExemplar ID: #{exemplar.id}"
              )

              nil
          end

        element_type =
          case ElementTypes.find_or_create_element_type(%{name: start[:tag_name]}) do
            {:ok, element_type} ->
              element_type

            {:error, reason} ->
              IO.inspect("There was an error finding or creating an ElementType: #{reason}")
              nil
          end

        end_node =
          TextNodes.get_by(%{
            exemplar_id: exemplar.id,
            location: matching_end[:location]
          })

        start_node = TextNodes.get_by(%{exemplar_id: exemplar.id, location: start[:location]})

        unless is_nil(start_node) or is_nil(end_node) do
          TextElements.find_or_create_text_element(%{
            attributes: start[:attributes],
            element_type_id: element_type.id,
            end_offset: matching_end[:offset] || 0,
            end_text_node_id: end_node.id,
            start_offset: start[:offset] || 0,
            start_text_node_id: start_node.id
          })
        end
      end)
    end)
  end

  def process_exemplar_text_nodes(exemplar, nodes) do
    Enum.each(nodes, fn el ->
      TextNodes.find_or_create_text_node(%{
        exemplar_id: exemplar.id,
        location: el[:location],
        text: el[:content]
      })
    end)
  end

  defp parse_exemplar_docx(%Exemplar{} = exemplar) do
    # We're just going to open the file in memory for now,
    # but if this causes issues we can set {:cwd, 'some_tmp_dir'}
    # and just clean up the files later
    {:ok, zip_handle} = :zip.zip_open(String.to_charlist(exemplar.filename), [:memory])
    {:ok, doc} = parse_zipped_xml(zip_handle, "word/document.xml")
    # {:ok, endnotes} = parse_zipped_xml(zip_handle, "word/endnotes.xml")
    # {:ok, footnotes} = parse_zipped_xml(zip_handle, "word/footnotes.xml")
    # {:ok, people} = parse_zipped_xml(zip_handle, "word/people.xml")

    {:ok, parsed_doc} =
      Saxy.parse_string(
        doc,
        Xml.Docx.ChsDocumentHandler,
        %{
          text_elements: []
        }
      )

    process_exemplar_text_nodes(
      exemplar,
      Enum.filter(parsed_doc[:text_elements], fn el -> Map.has_key?(el, :content) end)
    )

    process_exemplar_text_elements(exemplar, parsed_doc[:text_elements])

    :zip.zip_close(zip_handle)

    update_exemplar(exemplar, %{parsed_at: DateTime.utc_now()})
  end

  defp parse_zipped_xml(zip_handle, filename) do
    {:ok, {_name, binary}} = :zip.zip_get(String.to_charlist(filename), zip_handle)

    {:ok, binary}
  end

  defp parse_exemplar_xml(%Exemplar{} = exemplar) do
    {:ok, exemplar}
  end
end
