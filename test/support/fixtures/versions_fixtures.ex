defmodule TextServer.VersionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Versions` context.
  """

  def unique_version_filemd5hash, do: "some filemd5hash#{System.unique_integer([:positive])}"

  def unique_version_filename, do: "some filename#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique version urn.
  """
  def unique_version_urn, do: "some:urn#{System.unique_integer([:positive])}"

  @doc """
  Generate a version.
  """
  def version_fixture(attrs \\ %{}) do
    {:ok, version} =
      attrs
      |> Enum.into(%{
        description: "some description",
        filemd5hash: unique_version_filemd5hash(),
        filename: unique_version_filename(),
        label: "some title",
        language_id: language_fixture().id,
        parsed_at: DateTime.utc_now(),
        source: "some source",
        source_link: "https://some.source.link",
        tei_header: %TextServer.Versions.TeiHeader{
          id: nil,
          file_description: nil,
          profile_description: nil,
          revision_description: nil
        },
        urn: unique_version_urn(),
        version_type: version_type(),
        work_id: work_fixture().id
      })
      |> TextServer.Versions.create_version()

    text_node_fixture(version)

    version
  end

  def text_node_version_fixture(attrs \\ %{}) do
    {:ok, version} =
      attrs
      |> Enum.into(%{
        filemd5hash: unique_version_filemd5hash(),
        filename: unique_version_filename(),
        label: "some title",
        language_id: language_fixture().id,
        urn: unique_version_urn(),
        version_type: version_type(),
        work_id: work_fixture().id
      })
      |> TextServer.Versions.create_version()

    version
  end

  def text_node_fixture(version) do
    TextServer.TextNodesFixtures.version_text_node_fixture(version.id)
  end

  def version_with_docx_fixture(attrs \\ %{}) do
    version_fixture(
      attrs
      |> Enum.into(%{filename: Path.expand("test/support/fixtures/version.docx")})
    )
  end

  defp language_fixture() do
    TextServer.LanguagesFixtures.language_fixture()
  end

  defp version_type() do
    Enum.random([:commentary, :edition, :translation])
  end

  defp work_fixture() do
    TextServer.WorksFixtures.work_fixture()
  end
end
