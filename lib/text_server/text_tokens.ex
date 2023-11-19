defmodule TextServer.TextTokens do
  @moduledoc """
  The TextTokens context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.TextTokens.TextToken
  alias TextServer.TextTokens.TextElement, as: TextTokenTextElement

  @doc """
  Returns the list of text_tokens.

  ## Examples

      iex> list_text_tokens()
      [%TextToken{}, ...]

  """
  def list_text_tokens do
    Repo.all(TextToken)
  end

  @doc """
  Gets a single text_token.

  Raises `Ecto.NoResultsError` if the Text token does not exist.

  ## Examples

      iex> get_text_token!(123)
      %TextToken{}

      iex> get_text_token!(456)
      ** (Ecto.NoResultsError)

  """
  def get_text_token!(id), do: Repo.get!(TextToken, id)

  @doc """
  Creates a text_token.

  ## Examples

      iex> create_text_token(%{field: value})
      {:ok, %TextToken{}}

      iex> create_text_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_text_token(attrs \\ %{}) do
    %TextToken{}
    |> TextToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a text_token_text_element --- a join table mapping
  text elements that should be applied to a given text_token.
  """
  def create_text_token_text_element(attrs) do
    %TextTokenTextElement{}
    |> TextTokenTextElement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a text_token.

  ## Examples

      iex> update_text_token(text_token, %{field: new_value})
      {:ok, %TextToken{}}

      iex> update_text_token(text_token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_text_token(%TextToken{} = text_token, attrs) do
    text_token
    |> TextToken.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a text_token.

  ## Examples

      iex> delete_text_token(text_token)
      {:ok, %TextToken{}}

      iex> delete_text_token(text_token)
      {:error, %Ecto.Changeset{}}

  """
  def delete_text_token(%TextToken{} = text_token) do
    Repo.delete(text_token)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking text_token changes.

  ## Examples

      iex> change_text_token(text_token)
      %Ecto.Changeset{data: %TextToken{}}

  """
  def change_text_token(%TextToken{} = text_token, attrs \\ %{}) do
    TextToken.changeset(text_token, attrs)
  end
end
