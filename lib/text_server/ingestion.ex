defmodule TextServer.Ingestion do
  @moduledoc """
  The Ingestion context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Ingestion.Item

  @doc """
  Returns the list of ingestion_items.

  ## Examples

      iex> list_ingestion_items()
      [%Item{}, ...]

  """
  def list_ingestion_items do
    Repo.all(Item)
  end

  def list_ingestion_items_like(like_expression) do
    Repo.all(from i in Item, where: like(i.path, ^like_expression))
  end

  def list_ingestion_items_in_collection(collection_id) do
    Repo.all(from i in Item, where: i.collection_id == ^collection_id)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def insert_all_items(items \\ []) do
    Repo.insert_all({"ingestion_items", Item}, items, returning: true)
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def delete_all_items_by_paths(paths \\ []) when length(paths) > 0 do
    Repo.delete_all(from i in Item, where: i.path in ^paths)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
