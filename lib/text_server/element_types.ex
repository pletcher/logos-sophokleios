defmodule TextServer.ElementTypes do
  @moduledoc """
  The ElementTypes context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.ElementTypes.ElementType

  @doc """
  Returns the list of element_types.

  ## Examples

      iex> list_element_types()
      [%ElementType{}, ...]

  """
  def list_element_types do
    Repo.all(ElementType)
  end

  @doc """
  Gets a single element_type.

  Raises `Ecto.NoResultsError` if the Element type does not exist.

  ## Examples

      iex> get_element_type!(123)
      %ElementType{}

      iex> get_element_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_type!(id), do: Repo.get!(ElementType, id)

  @doc """
  Creates a element_type.

  ## Examples

      iex> create_element_type(%{field: value})
      {:ok, %ElementType{}}

      iex> create_element_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_type(attrs \\ %{}) do
    %ElementType{}
    |> ElementType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_type.

  ## Examples

      iex> update_element_type(element_type, %{field: new_value})
      {:ok, %ElementType{}}

      iex> update_element_type(element_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_type(%ElementType{} = element_type, attrs) do
    element_type
    |> ElementType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_type.

  ## Examples

      iex> delete_element_type(element_type)
      {:ok, %ElementType{}}

      iex> delete_element_type(element_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_type(%ElementType{} = element_type) do
    Repo.delete(element_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_type changes.

  ## Examples

      iex> change_element_type(element_type)
      %Ecto.Changeset{data: %ElementType{}}

  """
  def change_element_type(%ElementType{} = element_type, attrs \\ %{}) do
    ElementType.changeset(element_type, attrs)
  end
end
