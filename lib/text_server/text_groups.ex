defmodule TextServer.TextGroups do
  @moduledoc """
  The TextGroups context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.TextGroups.TextGroup

  @doc """
  Returns the list of text_groups.

  ## Examples

      iex> list_text_groups()
      [%TextGroup{}, ...]

  """
  def list_text_groups(attrs \\ %{}) do
    TextGroup
    |> where(^filter_text_group_where(attrs))
    |> limit(^limit_text_group(attrs))
    |> offset(^offset_text_group(attrs))
    |> Repo.all()
  end

  def list_text_groups_in_collection(%TextServer.Collections.Collection{} = collection, attrs \\ %{}) do
    TextGroup
    |> where([t], t.collection_id == ^collection.id)
    |> where(^filter_text_group_where(attrs))
    |> limit(^limit_text_group(attrs))
    |> offset(^offset_text_group(attrs))
    |> Repo.all()
  end

  def limit_text_group({"limit", value}), do: value

  def limit_text_group(_), do: 20

  def offset_text_group({"offset", value}), do: value

  def offset_text_group(_), do: 0

  def filter_text_group_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"urn", value}, dynamic ->
        dynamic([tg], ^dynamic and tg.urn == ^value)

      {"textsearch", value}, dynamic ->
        dynamic([tg], ^dynamic and ilike(tg.textsearch, fragment("%?%", ^value)))

      {_, _}, dynamic ->
        dynamic
    end)
  end

  @doc """
  Gets a single text_group.

  Raises `Ecto.NoResultsError` if the Text group does not exist.

  ## Examples

      iex> get_text_group!(123)
      %TextGroup{}

      iex> get_text_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_text_group!(id), do: Repo.get!(TextGroup, id)

  @doc """
  Creates a text_group.

  ## Examples

      iex> create_text_group(%{field: value})
      {:ok, %TextGroup{}}

      iex> create_text_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_text_group(attrs \\ %{}) do
    %TextGroup{}
    |> TextGroup.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_text_group(attrs \\ %{}) do
    query = from(t in TextGroup, where: t.urn == ^attrs[:urn])

    case Repo.one(query) do
      nil ->
        {:ok, new_text_group} = create_text_group(attrs)

      text_group ->
        {:ok, text_group}
    end
  end

  @doc """
  Updates a text_group.

  ## Examples

      iex> update_text_group(text_group, %{field: new_value})
      {:ok, %TextGroup{}}

      iex> update_text_group(text_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_text_group(%TextGroup{} = text_group, attrs) do
    text_group
    |> TextGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a text_group.

  ## Examples

      iex> delete_text_group(text_group)
      {:ok, %TextGroup{}}

      iex> delete_text_group(text_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_text_group(%TextGroup{} = text_group) do
    Repo.delete(text_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking text_group changes.

  ## Examples

      iex> change_text_group(text_group)
      %Ecto.Changeset{data: %TextGroup{}}

  """
  def change_text_group(%TextGroup{} = text_group, attrs \\ %{}) do
    TextGroup.changeset(text_group, attrs)
  end
end
