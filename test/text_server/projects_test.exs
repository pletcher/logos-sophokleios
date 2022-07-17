defmodule TextServer.ProjectsTest do
  use TextServer.DataCase

  alias TextServer.Projects

  describe "project" do
    alias TextServer.Projects.Project

    import TextServer.ProjectsFixtures

    @invalid_attrs %{description: nil, domain: nil}

    test "list_project/0 returns all project" do
      project = project_fixture()
      assert Projects.list_project() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{description: "some description", domain: "some domain"}

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.description == "some description"
      assert project.domain == "some domain"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      update_attrs = %{description: "some updated description", domain: "some updated domain"}

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.description == "some updated description"
      assert project.domain == "some updated domain"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end

  describe "exemplars" do
    alias TextServer.Projects.Exemplar

    import TextServer.ProjectsFixtures

    @invalid_attrs %{}

    test "list_exemplars/0 returns all exemplars" do
      exemplar = exemplar_fixture()
      assert Projects.list_exemplars() == [exemplar]
    end

    test "get_exemplar!/1 returns the exemplar with given id" do
      exemplar = exemplar_fixture()
      assert Projects.get_exemplar!(exemplar.id) == exemplar
    end

    test "create_exemplar/1 with valid data creates a exemplar" do
      valid_attrs = %{}

      assert {:ok, %Exemplar{} = exemplar} = Projects.create_exemplar(valid_attrs)
    end

    test "create_exemplar/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_exemplar(@invalid_attrs)
    end

    test "update_exemplar/2 with valid data updates the exemplar" do
      exemplar = exemplar_fixture()
      update_attrs = %{}

      assert {:ok, %Exemplar{} = exemplar} = Projects.update_exemplar(exemplar, update_attrs)
    end

    test "update_exemplar/2 with invalid data returns error changeset" do
      exemplar = exemplar_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_exemplar(exemplar, @invalid_attrs)
      assert exemplar == Projects.get_exemplar!(exemplar.id)
    end

    test "delete_exemplar/1 deletes the exemplar" do
      exemplar = exemplar_fixture()
      assert {:ok, %Exemplar{}} = Projects.delete_exemplar(exemplar)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_exemplar!(exemplar.id) end
    end

    test "change_exemplar/1 returns a exemplar changeset" do
      exemplar = exemplar_fixture()
      assert %Ecto.Changeset{} = Projects.change_exemplar(exemplar)
    end
  end
end
