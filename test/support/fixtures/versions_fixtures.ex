defmodule TextServer.VersionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Versions` context.
  """

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
        label: "some title",
        urn: unique_version_urn(),
        version_type: version_type(),
        work_id: work_fixture().id
      })
      |> TextServer.Versions.create_version()

    version
  end

  defp version_type() do
    Enum.random([:commentary, :edition, :translation])
  end

  defp work_fixture() do
    TextServer.WorksFixtures.work_fixture()
  end
end
