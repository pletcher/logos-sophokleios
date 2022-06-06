defmodule TextServer.RefsDeclsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.RefsDecls` context.
  """

  @doc """
  Generate a unique refs_decl slug.
  """
  def unique_refs_decl_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a refs_decl.
  """
  def refs_decl_fixture(attrs \\ %{}) do
    {:ok, refs_decl} =
      attrs
      |> Enum.into(%{
        description: "some description",
        label: "some label",
        match_pattern: "some match_pattern",
        replacement_pattern: "some replacement_pattern",
        slug: unique_refs_decl_slug(),
        structure_index: 42,
        urn: "some urn"
      })
      |> TextServer.RefsDecls.create_refs_decl()

    refs_decl
  end
end
