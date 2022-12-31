defmodule TextServer.TextNodes do
  @moduledoc """
  The TextNodes context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.TextElements.TextElement
  alias TextServer.TextNodes.TextNode

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
    text_elements_query = from te in TextElement, order_by: te.start_offset

    query =
      from(
        t in TextNode,
        where: t.version_id == ^version_id,
        order_by: [asc: t.location],
        preload: [text_elements: ^{text_elements_query, [:element_type]}]
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
  Returns a list of TextNodes between start_location and end_location.

  Used by Exemplars.get_version_page/2 and Exemplars.get_version_page_by_location/2.

  ## Examples

      iex> get_text_nodes_by_version_between_locations(1, [1, 1, 1], [1, 1, 2])
      [%TextNode{location: [1, 1, 1], ...}, %TextNode{location: [1, 1, 2], ...}]
  """

  def get_text_nodes_by_version_between_locations(version_id, start_location, end_location) do
    text_elements_query = from te in TextElement, order_by: te.start_offset

    query =
      from(
        t in TextNode,
        where:
          t.version_id == ^version_id and
            t.location >= ^start_location and
            t.location <= ^end_location,
        order_by: [asc: t.location],
        preload: [text_elements: ^{text_elements_query, [:element_type]}]
      )

    Repo.all(query)
  end

  def tag_text_nodes(text_nodes \\ []) do
    Enum.map(text_nodes, &TextNode.tag_graphemes/1)
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
  def get_text_node!(id), do: Repo.get!(TextNode, id)

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
