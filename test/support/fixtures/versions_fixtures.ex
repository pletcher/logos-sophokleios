defmodule TextServer.VersionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Versions` context.
  """

  @doc """
  Generate a unique version slug.
  """
  def unique_version_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique version urn.
  """
  def unique_version_urn, do: "some urn#{System.unique_integer([:positive])}"

  @doc """
  Generate a version.
  """
  def version_fixture(attrs \\ %{}) do
    {:ok, version} =
      attrs
      |> Enum.into(%{
        description: "some description",
        slug: unique_version_slug(),
        title: "some title",
        urn: unique_version_urn()
      })
      |> TextServer.Versions.create_version()

    version
  end
end
