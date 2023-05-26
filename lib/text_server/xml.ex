defmodule TextServer.Xml do
  @moduledoc """
  The XML context.
  """

  import Ecto.Query, warn: false
  import SweetXml
  alias TextServer.Repo

  alias TextServer.Xml.RefsDeclaration
  alias TextServer.Xml.Version

  @doc """
  Returns the list of xml_versions.

  ## Examples

      iex> list_xml_versions()
      [%Version{}, ...]

  """
  def list_xml_versions do
    Repo.all(Version)
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

  def get_version_by_urn(urn) do
    Version
    |> where([v], v.urn == ^urn)
    |> preload(:refs_declaration)
    |> Repo.one()
  end

  def get_version_by_urn!(urn) do
    Version
    |> where([v], v.urn == ^urn)
    |> preload(:refs_declaration)
    |> Repo.one!()
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

  def create_refs_declaration(attrs \\ %{}) do
    %RefsDeclaration{}
    |> RefsDeclaration.changeset(attrs)
    |> Repo.insert()
  end

  def get_refs_declaration!(id), do: Repo.get!(RefsDeclaration, id)

  def update_refs_declaration(%RefsDeclaration{} = refs_decl, attrs) do
    refs_decl
    |> RefsDeclaration.changeset(attrs)
    |> Repo.update()
  end

  def get_version_reference("urn:cts:" <> _rest = urn) do
    ["urn", "cts", collection, work, passage] = String.split(urn, ":")
    version = get_version_by_urn!("urn:cts:#{collection}:#{work}")
    path = get_ref_xpath(passage, version.refs_declaration)

    # NOTE: We cannot use SweetXML/:xmerl because
    # it chokes on the xml-model declaration. So
    # unfortunately we need to make another database query.
    Version
    |> where([v], v.id == ^version.id)
    |> select(
      fragment(
        """
        xpath(?,
          xml_document,
          ARRAY[ARRAY['tei', 'http://www.tei-c.org/ns/1.0']]
        )::text[]
        """,
        ^path
      )
    )
    |> Repo.one()
    |> List.first()
  end

  def get_ref_xpath(passage, refs_decl) do
    get_replacement_pattern(passage, refs_decl.replacement_patterns, refs_decl.match_patterns)
  end

  defp get_replacement_pattern(_passage, _replacement_patterns, []) do
    {:error, "Passage reference not found!"}
  end

  defp get_replacement_pattern(passage, replacement_patterns, match_patterns) do
    [potential_match | others] = match_patterns
    regex = Regex.compile!(potential_match)

    if refs = Regex.run(regex, passage, capture: :all_but_first) do
      idx = Enum.count(replacement_patterns) - Enum.count(match_patterns)
      replacement_pattern = Enum.at(replacement_patterns, idx)
      replacements = Enum.with_index(refs, 1) |> Enum.map(fn {ref, i} -> {ref, "$#{i}"} end)
      s = replace_refs(replacement_pattern, replacements)

      extract_path(s)
    else
      get_replacement_pattern(passage, replacement_patterns, others)
    end
  end

  defp replace_refs(s, []), do: s

  defp replace_refs(s, replacements) do
    [{ref, replacement} | rest] = replacements

    replace_refs(String.replace(s, replacement, ref), rest)
  end

  @tei_xpath_regex ~r/xpath\((?<path>.*)\)/

  defp extract_path(s) do
    Regex.named_captures(@tei_xpath_regex, s) |> Map.get("path")
  end

  def set_version_refs_declaration(%Version{} = version) do
    refs_decl = get_refs_decl(version)
    delimiters = get_delimiters(refs_decl)
    match_patterns = get_match_patterns(refs_decl)
    replacement_patterns = get_replacement_patterns(refs_decl)
    units = get_unit_labels(refs_decl)

    create_refs_declaration(%{
      delimiters: delimiters,
      match_patterns: match_patterns,
      raw: refs_decl,
      replacement_patterns: replacement_patterns,
      units: units,
      xml_version_id: version.id
    })
  end

  def get_refs_decl(%Version{} = version) do
    Version
    |> where([v], v.id == ^version.id)
    |> select(
      fragment(
        """
        xpath(?,
          xml_document,
          ARRAY[ARRAY['tei', 'http://www.tei-c.org/ns/1.0']]
        )::text[]
        """,
        ^refs_decl_xpath()
      )
    )
    |> Repo.one()
    |> List.first()
  end

  defp refs_decl_xpath() do
    "/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:refsDecl"
  end

  defp get_delimiters(refs_decl) do
    xpath(refs_decl, delimiters_xpath())
  end

  defp delimiters_xpath() do
    ~x"//refsDecl/cRefPattern/@delimiter"sl
  end

  defp get_match_patterns(refs_decl) do
    xpath(refs_decl, match_patterns_xpath())
  end

  defp match_patterns_xpath() do
    ~x"//refsDecl/cRefPattern/@matchPattern"sl
  end

  defp get_replacement_patterns(refs_decl) do
    xpath(refs_decl, replacement_patterns_xpath())
  end

  defp replacement_patterns_xpath() do
    ~x"//refsDecl/cRefPattern/@replacementPattern"sl
  end

  defp get_unit_labels(refs_decl) do
    xpath(refs_decl, unit_labels_xpath()) |> Enum.reverse()
  end

  defp unit_labels_xpath() do
    ~x"//refsDecl/cRefPattern/@n"sl
  end

  @doc """
  Determine's a version's table of contents as an array of
  xpath queries. So far, it looks like Perseus and First Thousand Years
  break documents up either as <card> elements or as <milestone unit="card">
  elements.

  We'll want to provide a way for editors to override these queries ---
  for example, the cards in tragic odes should cover whole odes,
  not just one strophe at a time.

  Maybe one fallback could involve using the second-most fine-grained
  refs division, like we do for Pausanias: each page is a chapter.
  """
  def set_version_table_of_contents(%Version{} = _version) do
    # refs declarations should have their
    # own database tables

    # refs declarations: id, xml_version_id, unit, delimiter, xpath
    # tables of contents should be handled by the `version_passages` table
    # we need to add a `urn` column to that table
  end
end
