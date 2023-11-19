defmodule TextServer.TextNodes do
  @moduledoc """
  The TextNodes context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.TextNodes.TextNode
  alias TextServer.Versions
  alias TextServer.Versions.Version

  @doc """
  Returns the list of text_nodes.

  ## Examples

      iex> list_text_nodes()
      [%TextNode{}, ...]

  """
  def list_text_nodes do
    Repo.paginate(TextNode)
  end

  @doc """
  Returns a paginated list of text_nodes with their text_elements,
  based on version_id.

  This function is especially useful for the ReadingEnvironment.

  ## Examples

      iex> list_text_nodes_by_version_id(1, [page_size: 20, page: 2])
      %Scrivener.Page{
        entries: [
          %TextNode{
            text_elements: [%TextElement{}, ...],
            ...
          },
          ...
        ],
        page_number: 2,
        page_size: 20,
        total_pages: 4
      }
  """
  def list_text_nodes_by_version_id(version_id, params \\ [page_size: 20]) do
    query =
      from(
        t in TextNode,
        where: t.version_id == ^version_id,
        order_by: [asc: t.location],
        preload: [text_elements: :element_type]
      )

    Repo.paginate(query, params)
  end

  @doc """
  Returns an ordered list of TextNode locations for the given version.

  ## Examples

      iex> list_text_node_locations_by_version_id(1)
      [[1, 1, 1], [1, 1, 2], [1, 1, 3], ...]
  """

  def list_locations_by_version_id(version_id) do
    query =
      from(
        t in TextNode,
        where: t.version_id == ^version_id,
        order_by: [asc: t.location],
        select: t.location
      )

    Repo.all(query)
  end

  @doc """
  Lists TextNodes from other versions of the same work
  at the same location.
  """
  def list_text_node_critica(nil), do: []

  def list_text_node_critica([%TextNode{}] = text_nodes) do
    [tn | _rest] = text_nodes
    version_ids = Versions.list_versions_for_urn(tn.urn) |> Enum.reject(&(&1 == tn.version_id))
    locations = Enum.map(text_nodes, & &1.location)

    from(
      t in TextNode,
      where: t.version_id in ^version_ids and t.location in ^locations,
      limit: 10,
      preload: :version
    )
    |> Repo.all()
  end

  def list_text_node_critica(%TextNode{} = text_node) do
    version_ids =
      Versions.list_versions_for_urn(text_node.urn)
      |> Enum.reject(&(&1.id == text_node.version_id))
      |> Enum.map(& &1.id)

    from(
      t in TextNode,
      where: t.version_id in ^version_ids and t.location == ^text_node.location,
      limit: 10,
      preload: :version
    )
    |> Repo.all()
  end

  @doc """
  Returns a list of TextNodes between start_location and end_location.

  Used by Exemplars.get_version_page/2 and Exemplars.get_version_page_by_location/2.

  ## Examples

      iex> list_text_nodes_by_version_between_locations(%Version{id: 1}, [1, 1, 1], [1, 1, 2])
      [%TextNode{location: [1, 1, 1], ...}, %TextNode{location: [1, 1, 2], ...}]
  """
  def list_text_nodes_by_version_between_locations(
        %Version{} = version,
        start_location,
        end_location
      ) do
    query =
      from(
        t in TextNode,
        where:
          t.version_id == ^version.id and
            t.location >= ^start_location and
            t.location <= ^end_location,
        order_by: [asc: t.location],
        preload: [:version, :text_tokens, text_elements: [:element_type, :text_element_users]]
      )

    Repo.all(query)
  end

  def list_text_nodes_by_version_between_locations(version_id, start_location, end_location)
      when is_integer(version_id) do
    list_text_nodes_by_version_between_locations(
      %Version{id: version_id},
      start_location,
      end_location
    )
  end

  def list_text_nodes_by_version_between_locations(version_id, start_location, end_location)
      when is_binary(version_id) do
    list_text_nodes_by_version_between_locations(
      %Version{id: version_id},
      start_location,
      end_location
    )
  end

  @spec list_text_nodes_by_version_from_start_location(%Version{}, [...]) :: [%TextNode{}]
  def list_text_nodes_by_version_from_start_location(%Version{} = version, start_location) do
    cardinality = Enum.count(start_location)
    pseudo_page_number = Enum.at(start_location, cardinality - 2)

    query =
      from(
        t in TextNode,
        where:
          t.version_id == ^version.id and
            t.location >= ^start_location and
            fragment("location[?] = ?", ^cardinality - 1, ^pseudo_page_number) and
            fragment("location[1] = ?", ^List.first(start_location)),
        order_by: [asc: t.location],
        preload: [text_elements: [:element_type, :text_element_users]]
      )

    Repo.all(query)
  end

  def tag_text_nodes(text_nodes \\ []) do
    Enum.map(text_nodes, &TextNode.tag_graphemes/1)
  end

  def tag_text_node(%TextNode{} = text_node) do
    TextNode.tag_graphemes(text_node)
  end

  @doc """
  "Tokenizes" a TextNode's `text` attribute by splitting on
  whitespace. For convenience, also returns a "cleaned"
  version of the token (without punctuation). We don't actually need a 
  full-fledged tokenizer here, as we're mainly interested in 
  getting the word-like components of a TextNode's `text`. 
  We can tokenize/lemmatize more robustly --- and accurately --- 
  later.

  One inaccuracy that we're just going to accept for the moment
  has to do with dashes. For example, there is a line in the Nagy
  translation of Pausanias that goes, "Xenophon among others has 
  written a history of the whole war—the taking of the ...".

  This "tokenization" method will treat "war—the" as a single token.
  This minor bug shouldn't ultimately matter for the moment, since
  we can still attach TextElements to tokens based on their offsets.
  But we should be aware of this issue in case it causes problems
  in the future.

  Returns a list of `{token, word, offset}` tuples in document
  order.

  ## Examples
      iex> tokenize_text_node(%TextNode{text: "a b c"})
      [{"a", "a", 0}, {"b", "b", 2}, {"c", "c", 3}]

      iex> tokenize_text_node(%TextNode{text: "abc· [def]"})
      [{"abc·", "abc", 0}, {"[def]", "def", 5}]
  """
  def tokenize_text_node(%TextNode{} = text_node) do
    text = text_node.text

    {_last_offset, _leftover_text, tokens} =
      Regex.split(~r/[[:space:]]/u, text)
      |> Enum.reduce({0, text, []}, fn token, {current_offset, remaining_text, tokens} ->
        [before, aft] = String.split(remaining_text, token, parts: 2)
        offset = String.length(before) + current_offset
        word = Regex.replace(~r/[[:punct:]]/u, token, "")

        # We only retain the substring `aft`er the split in the accumulator
        # in order to handle potential repeated words.
        {offset + String.length(token), aft, [{token, word, offset} | tokens]}
      end)

    tokens |> Enum.reverse()
  end

  @doc """
  Gets a single text_node.

  Raises `Ecto.NoResultsError` if the Text node does not exist.

  ## Examples

      iex> get_text_node!(123)
      %TextNode{}

      iex> get_text_node!(456)
      ** (Ecto.NoResultsError)

  """
  def get_text_node!(id) do
    Repo.get!(TextNode, id)
    |> Repo.preload([:version, text_elements: [:element_type, :text_element_users]])
  end

  def get_by(attrs \\ %{}) do
    Repo.get_by(TextNode, attrs)
  end

  @doc """
  Creates a text_node.

  ## Examples

      iex> create_text_node(%{field: value})
      {:ok, %TextNode{}}

      iex> create_text_node(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_text_node(attrs \\ %{}) do
    %TextNode{}
    |> TextNode.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_text_node(attrs) do
    query =
      from(t in TextNode,
        where: t.version_id == ^attrs[:version_id] and t.location == ^attrs[:location]
      )

    case Repo.one(query) do
      nil -> create_text_node(attrs)
      text_node -> {:ok, text_node}
    end
  end

  @doc """
  Updates a text_node.

  ## Examples

      iex> update_text_node(text_node, %{field: new_value})
      {:ok, %TextNode{}}

      iex> update_text_node(text_node, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_text_node(%TextNode{} = text_node, attrs) do
    text_node
    |> TextNode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a text_node.

  ## Examples

      iex> delete_text_node(text_node)
      {:ok, %TextNode{}}

      iex> delete_text_node(text_node)
      {:error, %Ecto.Changeset{}}

  """
  def delete_text_node(%TextNode{} = text_node) do
    Repo.delete(text_node)
  end

  def delete_text_nodes_by_version_id(version_id) do
    query =
      from(
        t in TextNode,
        where: t.version_id == ^version_id
      )

    Repo.delete_all(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking text_node changes.

  ## Examples

      iex> change_text_node(text_node)
      %Ecto.Changeset{data: %TextNode{}}

  """
  def change_text_node(%TextNode{} = text_node, attrs \\ %{}) do
    TextNode.changeset(text_node, attrs)
  end
end
