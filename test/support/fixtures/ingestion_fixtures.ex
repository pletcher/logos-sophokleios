defmodule TextServer.IngestionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Ingestion` context.
  """

  @doc """
  Generate a unique item path.
  """
  def unique_item_path, do: "some path#{System.unique_integer([:positive])}"

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        path: unique_item_path()
      })
      |> TextServer.Ingestion.create_item()

    item
  end
end
