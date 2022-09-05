defmodule TextServer.ExemplarsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Exemplars` context.
  """

  def unique_exemplar_filemd5hash, do: "some filemd5hash#{System.unique_integer([:positive])}"
  def unique_exemplar_filename, do: "some filename#{System.unique_integer([:positive])}"

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
        filemd5hash: unique_exemplar_filemd5hash(),
        filename: unique_exemplar_filename(),
        language_id: language_fixture().id,
        title: "some title",
        urn: unique_exemplar_urn(),
        version_id: version_fixture().id
      })
      |> TextServer.Exemplars.create_exemplar()

    exemplar
  end

  def exemplar_with_docx_fixture(attrs \\ %{}) do
    exemplar_fixture(attrs |> Enum.into(%{filename: Path.expand("test/support/fixtures/exemplar.docx")}))
  end

  defp language_fixture() do
    TextServer.LanguagesFixtures.language_fixture()
  end

  defp version_fixture() do
    TextServer.VersionsFixtures.version_fixture()
  end
end
