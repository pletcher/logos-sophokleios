defmodule TextServer.LanguagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Languages` context.
  """

  @doc """
  Generate a unique language slug.
  """
  def unique_language_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique language title.
  """
  def unique_language_title, do: "some title#{System.unique_integer([:positive])}"

  @doc """
  Generate a language.
  """
  def language_fixture(attrs \\ %{}) do
    {:ok, language} =
      attrs
      |> Enum.into(%{
        slug: unique_language_slug(),
        title: unique_language_title()
      })
      |> TextServer.Languages.create_language()

    language
  end
end
