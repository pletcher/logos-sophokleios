defmodule TextServer.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        created_by_id: created_by_fixture().id,
        description: "some description",
        domain: "domain",
        homepage_copy: "# Markdown",
        title: "some title"
      })
      |> TextServer.Projects.create_project()

    project
  end

  @doc """
  Generate a project_version.
  """
  def project_version_fixture(attrs \\ %{}) do
    version = TextServer.VersionsFixtures.version_fixture()
    project = project_fixture()

    {:ok, project_version} =
      attrs
      |> Enum.into(%{version_id: version.id, project_id: project.id})
      |> TextServer.Projects.create_version()

    project_version
  end

  defp created_by_fixture() do
    TextServer.AccountsFixtures.user_fixture()
  end
end
