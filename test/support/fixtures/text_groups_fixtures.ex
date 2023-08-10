defmodule TextServer.TextGroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.TextGroups` context.
  """

  @doc """
  Generate a unique text_group slug.
  """
  def unique_text_group_slug, do: "some slug#{System.unique_integer([:positive])}"

  def unique_text_group_urn, do: "urn:cts:namespace:#{System.unique_integer([:positive])}"

  @doc """
  Generate a text_group.
  """
  def text_group_fixture(attrs \\ %{}) do
    {:ok, text_group} =
      attrs
      |> Enum.into(%{
        collection_id: collection_fixture().id,
        title: "some title",
        urn: unique_text_group_urn()
      })
      |> TextServer.TextGroups.create_text_group()

    text_group
  end

  defp collection_fixture() do
    TextServer.CollectionsFixtures.collection_fixture()
  end
end
