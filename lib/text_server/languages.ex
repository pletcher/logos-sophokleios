defmodule TextServer.Languages do
  @moduledoc """
  The Languages context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Languages.Language

  @doc """
  Returns the list of languages.

  ## Examples

      iex> list_languages()
      [%Language{}, ...]

  """
  def list_languages do
    Repo.all(Language)
  end

  @doc """
  Gets a single language.

  Raises `Ecto.NoResultsError` if the Language does not exist.

  ## Examples

      iex> get_language!(123)
      %Language{}

      iex> get_language!(456)
      ** (Ecto.NoResultsError)

  """
  def get_language!(id), do: Repo.get!(Language, id)

  def get_language_by_slug(slug) do
    query = from(l in Language, where: l.slug == ^slug)

    Repo.one(query)
  end

  @doc """
  Creates a language.

  ## Examples

      iex> create_language(%{field: value})
      {:ok, %Language{}}

      iex> create_language(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_language(attrs \\ %{}) do
    %Language{}
    |> Language.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_language(attrs \\ %{}) do
    query = from(l in Language, where: l.title == ^attrs[:title])

    case Repo.one(query) do
      nil ->
        {:ok, _new_language} = create_language(attrs)

      language ->
        {:ok, language}
    end
  end

  def get_by_slug(slug) do
    cleaned_slug =
      case slug do
        "eng" -> "en"
        "la" -> "lat"
        _ -> slug
      end

    Repo.get_by(Language, slug: cleaned_slug)
  end

  @doc """
  Updates a language.

  ## Examples

      iex> update_language(language, %{field: new_value})
      {:ok, %Language{}}

      iex> update_language(language, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_language(%Language{} = language, attrs) do
    language
    |> Language.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a language.

  ## Examples

      iex> delete_language(language)
      {:ok, %Language{}}

      iex> delete_language(language)
      {:error, %Ecto.Changeset{}}

  """
  def delete_language(%Language{} = language) do
    Repo.delete(language)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking language changes.

  ## Examples

      iex> change_language(language)
      %Ecto.Changeset{data: %Language{}}

  """
  def change_language(%Language{} = language, attrs \\ %{}) do
    Language.changeset(language, attrs)
  end
end
