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
  Takes parsed TEI header data and returns an ordered list
  of ref levels. Note that it expects data in reversed
  order because of how the SAX handler prepends elements.

  Defaults to ["line"] in texts with only one level
  of hierarchy.

  ## Examples

      iex> get_ref_levels_from_tei_header([%{
        tag_name: "refState",
        attributes: [["unit", "section"], ["unit", "book"]]
      }])
      ["book", "section"]

      iex> get_ref_levels_from_tei_header([%{}])
      ["line"]
  """
  def get_ref_levels_from_tei_header(header_data) do
    cref_pattern_units = get_cref_pattern_units(header_data)

    units =
      if Enum.empty?(cref_pattern_units) do
        get_ref_state_units(header_data) |> Enum.reverse()
      else
        cref_pattern_units
      end

    units
  end

  defp get_cref_pattern_units(header_data) do
    header_data
    |> Enum.filter(fn d -> Map.get(d, :tag_name) == "cRefPattern" end)
    |> Enum.map(fn r ->
      Map.get(r, :attributes)
      |> Enum.find_value(fn a ->
        if elem(a, 0) == "n" do
          String.downcase(elem(a, 1))
        end
      end)
    end)
  end

  defp get_ref_state_units(header_data) do
    header_data
    |> Enum.filter(fn d -> Map.get(d, :tag_name) == "refState" end)
    |> Enum.map(fn r ->
      Map.get(r, :attributes)
      |> Enum.find_value(fn a ->
        if elem(a, 0) == "unit" do
          elem(a, 1)
        end
      end)
    end)
  end

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
