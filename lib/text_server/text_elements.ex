defmodule TextServer.TextElements do
  @moduledoc """
  The TextElements context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.TextElements.TextElement

  @doc """
  Returns the list of text_elements.

  ## Examples

      iex> list_text_elements()
      [%TextElement{}, ...]

  """
  def list_text_elements do
    Repo.all(TextElement)
  end

  @doc """
  Gets a single text_element.

  Raises `Ecto.NoResultsError` if the Text element does not exist.

  ## Examples

      iex> get_text_element!(123)
      %TextElement{}

      iex> get_text_element!(456)
      ** (Ecto.NoResultsError)

  """
  def get_text_element!(id), do: Repo.get!(TextElement, id)

  @doc """
  Creates a text_element.

  ## Examples

      iex> create_text_element(%{field: value})
      {:ok, %TextElement{}}

      iex> create_text_element(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_text_element(attrs \\ %{}) do
    %TextElement{}
    |> TextElement.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_text_element(attrs) do
    query =
      from(t in TextElement,
        where:
          t.element_type_id == ^attrs[:element_type_id] and
            t.end_offset == ^attrs[:end_offset] and
            t.end_text_node_id == ^attrs[:end_text_node_id] and
            t.start_offset == ^attrs[:start_offset] and
            t.start_text_node_id == ^attrs[:start_text_node_id]
      )

    case Repo.one(query) do
      nil -> create_text_element(attrs)
      element -> {:ok, element}
    end
  end

  @doc """
  Updates a text_element.

  ## Examples

      iex> update_text_element(text_element, %{field: new_value})
      {:ok, %TextElement{}}

      iex> update_text_element(text_element, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_text_element(%TextElement{} = text_element, attrs) do
    text_element
    |> TextElement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a text_element.

  ## Examples

      iex> delete_text_element(text_element)
      {:ok, %TextElement{}}

      iex> delete_text_element(text_element)
      {:error, %Ecto.Changeset{}}

  """
  def delete_text_element(%TextElement{} = text_element) do
    Repo.delete(text_element)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking text_element changes.

  ## Examples

      iex> change_text_element(text_element)
      %Ecto.Changeset{data: %TextElement{}}

  """
  def change_text_element(%TextElement{} = text_element, attrs \\ %{}) do
    TextElement.changeset(text_element, attrs)
  end
end
