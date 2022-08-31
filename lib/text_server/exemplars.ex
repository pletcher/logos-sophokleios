defmodule TextServer.Exemplars do
  @moduledoc """
  The Exemplars context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Exemplars.Exemplar

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
    %Exemplar{}
    |> Exemplar.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a user-uploaded exemplar with its associated file.

  Wraps both insertions in a transaction.
  ## Examples

      iex> create_exemplar_with_file(%{field: value}, %{field: value})
      {:ok, %Exemplar{}}

      iex> create_exemplar_with_file(%{field: bad_value}, %{field: value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exemplar_with_file(exemplar_attrs, file_attrs) do
    Repo.transaction(fn ->
      exemplar = %Exemplar{} |> Exemplar.changeset(exemplar_attrs) |> Repo.insert!()
      _file = exemplar |> Ecto.build_assoc(:file, file_attrs) |> Repo.insert!()

      {:ok, exemplar}
    end)
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
  Updates an exemplar and its associated file.

  Wraps updates in a transaction.

  ## Examples

      iex> update_exemplar(exemplar, %{field: new_value})
      {:ok, %Exemplar{}}

      iex> update_exemplar(exemplar, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_exemplar_with_file(%Exemplar{} = exemplar, exemplar_attrs, file_attrs) do
    Repo.transaction(fn ->
      updated_exemplar = exemplar |> Exemplar.changeset(exemplar_attrs) |> Repo.update!()
      _file = updated_exemplar |> Ecto.build_assoc(:file, file_attrs) |> Repo.update!()

      {:ok, updated_exemplar}
    end)
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
end
