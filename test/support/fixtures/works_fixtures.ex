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
end
