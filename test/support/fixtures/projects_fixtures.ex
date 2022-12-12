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
  Generate a project_exemplar.
  """
  def project_exemplar_fixture(attrs \\ %{}) do
    exemplar = TextServer.ExemplarsFixtures.exemplar_fixture()
    project = project_fixture()

    {:ok, project_exemplar} =
      attrs
      |> Enum.into(%{exemplar_id: exemplar.id, project_id: project.id})
      |> TextServer.Projects.create_exemplar()

    project_exemplar
  end

  defp created_by_fixture() do
    TextServer.AccountsFixtures.user_fixture()
  end
end
