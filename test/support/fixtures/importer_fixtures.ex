defmodule TextServer.ImporterFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Importer` context.
  """

  @doc """
  Generate a collection.
  """
  def collection_fixture(attrs \\ %{}) do
    {:ok, collection} =
      attrs
      |> Enum.into(%{

      })
      |> TextServer.Importer.create_collection()

    collection
  end

  @doc """
  Generate a repository.
  """
  def repository_fixture(attrs \\ %{}) do
    {:ok, repository} =
      attrs
      |> Enum.into(%{

      })
      |> TextServer.Importer.create_repository()

    repository
  end
end
