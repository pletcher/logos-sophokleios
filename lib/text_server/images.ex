defmodule TextServer.Images do
  @moduledoc """
  The Images context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Images.CoverImage

  @doc """
  Returns the list of cover_images.

  ## Examples

      iex> list_cover_images()
      [%CoverImage{}, ...]

  """
  def list_cover_images do
    Repo.all(CoverImage)
  end

  @doc """
  Gets a single cover_image.

  Raises `Ecto.NoResultsError` if the Cover image does not exist.

  ## Examples

      iex> get_cover_image!(123)
      %CoverImage{}

      iex> get_cover_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cover_image!(id), do: Repo.get!(CoverImage, id)

  @doc """
  Creates a cover_image.

  ## Examples

      iex> create_cover_image(%{field: value})
      {:ok, %CoverImage{}}

      iex> create_cover_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cover_image(attrs \\ %{}) do
    %CoverImage{}
    |> CoverImage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cover_image.

  ## Examples

      iex> update_cover_image(cover_image, %{field: new_value})
      {:ok, %CoverImage{}}

      iex> update_cover_image(cover_image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cover_image(%CoverImage{} = cover_image, attrs) do
    cover_image
    |> CoverImage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cover_image.

  ## Examples

      iex> delete_cover_image(cover_image)
      {:ok, %CoverImage{}}

      iex> delete_cover_image(cover_image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cover_image(%CoverImage{} = cover_image) do
    Repo.delete(cover_image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cover_image changes.

  ## Examples

      iex> change_cover_image(cover_image)
      %Ecto.Changeset{data: %CoverImage{}}

  """
  def change_cover_image(%CoverImage{} = cover_image, attrs \\ %{}) do
    CoverImage.changeset(cover_image, attrs)
  end
end
