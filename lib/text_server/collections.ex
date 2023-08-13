defmodule TextServer.Collections do
  @moduledoc """
  The Collections context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Collections.Collection
  alias TextServer.Collections.Repository

  @doc """
  Returns the list of collections.

  ## Examples

      iex> list_collections()
      [%Collection{}, ...]

  """
  def list_collections do
    Repo.all(Collection)
  end

  def list_collections_with_repositories do
    Collection |> preload(:repositories)
    |> Repo.all()
  end

  @doc """
  Returns a paginated list of collections matching
  the given query.
  """
  def paginate_collections(params \\ []) do
    Collection
    |> Repo.paginate(params)
  end

  @doc """
  Gets a single collection.

  Raises `Ecto.NoResultsError` if the Collection does not exist.

  ## Examples

      iex> get_collection!(123)
      %Collection{}

      iex> get_collection!(456)
      ** (Ecto.NoResultsError)

  """
  def get_collection!(id), do: Repo.get!(Collection, id)

  @doc """
  Creates a collection.

  ## Examples

      iex> create_collection(%{field: value})
      {:ok, %Collection{}}

      iex> create_collection(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_collection(attrs \\ %{}) do
    %Collection{}
    |> Collection.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_collection(attrs \\ %{}) do
    query = from(c in Collection, where: c.urn == ^attrs[:urn])

    case Repo.one(query) do
      nil ->
        {:ok, _new_collection} = create_collection(attrs)

      collection ->
        {:ok, collection}
    end
  end

  @doc """
  Updates a collection.

  ## Examples

      iex> update_collection(collection, %{field: new_value})
      {:ok, %Collection{}}

      iex> update_collection(collection, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a collection.

  ## Examples

      iex> delete_collection(collection)
      {:ok, %Collection{}}

      iex> delete_collection(collection)
      {:error, %Ecto.Changeset{}}

  """
  def delete_collection(%Collection{} = collection) do
    Repo.delete(collection)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collection changes.

  ## Examples

      iex> change_collection(collection)
      %Ecto.Changeset{data: %Collection{}}

  """
  def change_collection(%Collection{} = collection, attrs \\ %{}) do
    Collection.changeset(collection, attrs)
  end

  @doc """
  Lists all repositories.

  ## Examples

      iex> list_repositories()
      [%Repository{}, ...]
  """
  def list_repositories do
    Repo.all(Repository)
  end

  @doc """
  Lists all repositories in a collection.

  ## Examples

      iex> list_collection_repositories(1)
      [%Repository{collection_id: 1}, ...]
  """
  def list_collection_repositories(collection_id) do
    Repository
    |> where(collection_id: ^collection_id)
    |> Repo.all()
  end

  @doc """
  Gets a repository.

  Raises `Ecto.NoResultsError` if the repository does not exist.

  ## Examples

      iex> get_repository!(1)
      %Repository{id: 1}
  """
  def get_repository!(id), do: Repo.get!(Repository, id)

  @doc """
  Creates a repository.

  ## Examples

      iex> create_repository(%{field: value})
      {:ok, %Repository{}}

      iex> create_repository(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_repository(attrs \\ %{}) do
    %Repository{}
    |> Repository.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_repository(attrs \\ %{}) do
    query = from(r in Repository, where: r.url == ^attrs[:url])

    case Repo.one(query) do
      nil ->
        {:ok, _new_repository} = create_repository(attrs)

      repository ->
        {:ok, repository}
    end
  end

    @doc """
  Updates a repository.

  ## Examples

      iex> update_repository(repository, %{field: new_value})
      {:ok, %Repository{}}

      iex> update_repository(repository, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_repository(%Repository{} = repository, attrs) do
    repository
    |> Repository.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a repository.

  ## Examples

      iex> delete_repository(repository)
      {:ok, %Repository{}}

      iex> delete_repository(repository)
      {:error, %Ecto.Changeset{}}

  """
  def delete_repository(%Repository{} = repository) do
    Repo.delete(repository)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking repository changes.

  ## Examples

      iex> change_repository(repository)
      %Ecto.Changeset{data: %Repository{}}

  """
  def change_repository(%Repository{} = repository, attrs \\ %{}) do
    Repository.changeset(repository, attrs)
  end
end
