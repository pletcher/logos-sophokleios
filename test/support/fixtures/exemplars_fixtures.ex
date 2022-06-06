defmodule TextServer.ExemplarsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Exemplars` context.
  """

  @doc """
  Generate a unique exemplar slug.
  """
  def unique_exemplar_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique exemplar urn.
  """
  def unique_exemplar_urn, do: "some urn#{System.unique_integer([:positive])}"

  @doc """
  Generate a exemplar.
  """
  def exemplar_fixture(attrs \\ %{}) do
    {:ok, exemplar} =
      attrs
      |> Enum.into(%{
        description: "some description",
        slug: unique_exemplar_slug(),
        title: "some title",
        urn: unique_exemplar_urn()
      })
      |> TextServer.Exemplars.create_exemplar()

    exemplar
  end
end
