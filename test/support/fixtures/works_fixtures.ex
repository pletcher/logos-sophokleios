defmodule TextServer.WorksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Works` context.
  """

  @doc """
  Generate a unique work filemd5hash.
  """
  def unique_work_filemd5hash, do: "some filemd5hash#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique work full_urn.
  """
  def unique_work_full_urn, do: "some full_urn#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique work slug.
  """
  def unique_work_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a work.
  """
  def work_fixture(attrs \\ %{}) do
    {:ok, work} =
      attrs
      |> Enum.into(%{
        description: "some description",
        english_title: "some english_title",
        filemd5hash: unique_work_filemd5hash(),
        filename: "some filename",
        form: "some form",
        full_urn: unique_work_full_urn(),
        label: "some label",
        original_title: "some original_title",
        slug: unique_work_slug(),
        structure: "some structure",
        urn: "some urn",
        work_type: :edition
      })
      |> TextServer.Works.create_work()

    work
  end

  @doc """
  Generate a unique edition slug.
  """
  def unique_edition_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique edition urn.
  """
  def unique_edition_urn, do: "some urn#{System.unique_integer([:positive])}"

  @doc """
  Generate a edition.
  """
  def edition_fixture(attrs \\ %{}) do
    {:ok, edition} =
      attrs
      |> Enum.into(%{
        description: "some description",
        slug: unique_edition_slug(),
        title: "some title",
        urn: unique_edition_urn()
      })
      |> TextServer.Works.create_edition()

    edition
  end

  @doc """
  Generate a unique translation slug.
  """
  def unique_translation_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique translation urn.
  """
  def unique_translation_urn, do: "some urn#{System.unique_integer([:positive])}"

  @doc """
  Generate a translation.
  """
  def translation_fixture(attrs \\ %{}) do
    {:ok, translation} =
      attrs
      |> Enum.into(%{
        description: "some description",
        slug: unique_translation_slug(),
        title: "some title",
        urn: unique_translation_urn()
      })
      |> TextServer.Works.create_translation()

    translation
  end

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
      |> TextServer.Works.create_version()

    version
  end

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
      |> TextServer.Works.create_refs_decl()

    refs_decl
  end
end
