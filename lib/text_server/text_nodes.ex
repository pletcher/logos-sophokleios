defmodule TextServer.TextNodes do
  @moduledoc """
  The TextNodes context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.TextNodes.TextNode

  @doc """
  Returns the list of text_nodes.

  ## Examples

      iex> list_text_nodes()
      [%TextNode{}, ...]

  """
  def list_text_nodes do
    Repo.all(TextNode)
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
        where: t.exemplar_id == ^attrs[:exemplar_id] and t.location == ^attrs[:location]
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
