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
        description: "some description",
        domain: "some domain"
      })
      |> TextServer.Projects.create_project()

    project
  end

  @doc """
  Generate a exemplar.
  """
  def exemplar_fixture(attrs \\ %{}) do
    {:ok, exemplar} =
      attrs
      |> Enum.into(%{

      })
      |> TextServer.Projects.create_exemplar()

    exemplar
  end
end
