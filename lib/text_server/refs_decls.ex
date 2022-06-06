defmodule TextServer.RefsDecls do
  @moduledoc """
  The RefsDecls context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.RefsDecls.RefsDecl

  @doc """
  Returns the list of refs_decls.

  ## Examples

      iex> list_refs_decls()
      [%RefsDecl{}, ...]

  """
  def list_refs_decls do
    Repo.all(RefsDecl)
  end

  @doc """
  Gets a single refs_decl.

  Raises `Ecto.NoResultsError` if the Refs decl does not exist.

  ## Examples

      iex> get_refs_decl!(123)
      %RefsDecl{}

      iex> get_refs_decl!(456)
      ** (Ecto.NoResultsError)

  """
  def get_refs_decl!(id), do: Repo.get!(RefsDecl, id)

  @doc """
  Creates a refs_decl.

  ## Examples

      iex> create_refs_decl(%{field: value})
      {:ok, %RefsDecl{}}

      iex> create_refs_decl(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_refs_decl(attrs \\ %{}) do
    %RefsDecl{}
    |> RefsDecl.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a refs_decl.

  ## Examples

      iex> update_refs_decl(refs_decl, %{field: new_value})
      {:ok, %RefsDecl{}}

      iex> update_refs_decl(refs_decl, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_refs_decl(%RefsDecl{} = refs_decl, attrs) do
    refs_decl
    |> RefsDecl.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a refs_decl.

  ## Examples

      iex> delete_refs_decl(refs_decl)
      {:ok, %RefsDecl{}}

      iex> delete_refs_decl(refs_decl)
      {:error, %Ecto.Changeset{}}

  """
  def delete_refs_decl(%RefsDecl{} = refs_decl) do
    Repo.delete(refs_decl)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking refs_decl changes.

  ## Examples

      iex> change_refs_decl(refs_decl)
      %Ecto.Changeset{data: %RefsDecl{}}

  """
  def change_refs_decl(%RefsDecl{} = refs_decl, attrs \\ %{}) do
    RefsDecl.changeset(refs_decl, attrs)
  end
end
