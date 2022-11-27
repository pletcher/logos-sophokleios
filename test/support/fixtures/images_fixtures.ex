defmodule TextServer.ImagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Images` context.
  """

  @doc """
  Generate a unique cover_image attribution_url.
  """
  def unique_cover_image_attribution_url,
    do: "some attribution_url#{System.unique_integer([:positive])}"

  @doc """
  Generate a cover_image.
  """
  def cover_image_fixture(attrs \\ %{}) do
    {:ok, cover_image} =
      attrs
      |> Enum.into(%{
        attribution_name: "some attribution_name",
        attribution_source: "some attribution_source",
        attribution_url: unique_cover_image_attribution_url(),
        attribution_source_url: "https://some.attribution_source_url",
        image_url: "some image_url"
      })
      |> TextServer.Images.create_cover_image()

    cover_image
  end
end
