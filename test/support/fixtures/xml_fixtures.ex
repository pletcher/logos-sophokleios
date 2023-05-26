defmodule TextServer.XmlFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Xml` context.
  """

  def unique_version_urn, do: "some:urn#{System.unique_integer([:positive])}"

  @doc """
  Generate a version.
  """
  def version_fixture(attrs \\ %{}) do
    {:ok, version} =
      attrs
      |> Enum.into(%{
        version_type: version_type(),
        urn: unique_version_urn(),
        work_id: work_fixture().id,
        xml_document: "<ul><li>foo</li></ul>"
      })
      |> TextServer.Xml.create_version()

    version
  end

  defp version_type() do
    Enum.random([:commentary, :edition, :translation])
  end

  defp work_fixture() do
    TextServer.WorksFixtures.work_fixture()
  end
end
