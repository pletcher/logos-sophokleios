defmodule TextServer.Exemplars do
  @moduledoc """
  The Exemplars context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Exemplars.Exemplar
  alias TextServer.Projects.Exemplar, as: ProjectExemplar

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

  def create_exemplar(attrs, project) do
	  Repo.transaction(fn ->
	  	{:ok, exemplar} =
	  	  %Exemplar{}
	  	  |> Exemplar.changeset(attrs)
	  	  |> Repo.insert()

	  	{:ok, _project_exemplar} =
	  		%ProjectExemplar{}
	  		|> ProjectExemplar.changeset(%{exemplar_id: exemplar.id, project_id: project.id})
	  		|> Repo.insert()

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
