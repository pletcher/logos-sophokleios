defmodule TextServer.ProjectsTest do
  import Ecto.Query, warn: false
  use TextServer.DataCase

  alias TextServer.Projects
  alias TextServer.Repo

  alias TextServer.Projects.Project
  alias TextServer.Projects.Exemplar, as: ProjectExemplar
  alias TextServer.TextGroups.TextGroup
  alias TextServer.Versions.Version
  alias TextServer.Works.Work

  import TextServer.AccountsFixtures
  import TextServer.ExemplarsFixtures
  import TextServer.ProjectsFixtures

  @invalid_attrs %{created_by_id: nil, description: nil, domain: "some domain", title: nil}

  defp create_creator(_) do
    user = user_fixture()
    %{user: user}
  end

  describe "project" do
    setup [:create_creator]

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with invalid domain returns error changeset", %{user: user} do
      bad_domain_attrs = %{
        created_by_id: user.id,
        description: "some description",
        domain: "some domain",
        title: "some title"
      }

      assert %Ecto.InvalidChangesetError{} = catch_error(Projects.create_project(bad_domain_attrs))
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{
        created_by_id: user_fixture().id,
        description: "some description",
        domain: "some_domain",
        title: "some title"
      }

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.description == "some description"
      assert project.domain == "some_domain"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert %Ecto.InvalidChangesetError{} = catch_error(Projects.create_project(@invalid_attrs))
    end

    test "add_collection/2 with valid data returns a list of ProjectExemplars" do
      project = project_fixture()
      exemplars = [exemplar_fixture(), exemplar_fixture()]
      version_ids = exemplars |> Enum.map(fn e -> e.version_id end)

      work_ids =
        from(v in Version, where: v.id in ^version_ids, select: [:work_id])
        |> Repo.all()
        |> Enum.map(fn v -> v.work_id end)

      text_group_ids =
        from(w in Work, where: w.id in ^work_ids, select: [:text_group_id])
        |> Repo.all()
        |> Enum.map(fn w -> w.text_group_id end)

      collection_ids =
        from(t in TextGroup, where: t.id in ^text_group_ids, select: [:collection_id])
        |> Repo.all()
        |> Enum.map(fn t -> t.collection_id end)

      Enum.each(collection_ids, fn c_id ->
        Enum.each(Projects.add_collection(project, c_id), fn pe ->
          assert {:ok, %ProjectExemplar{}} = pe
        end)
      end)
    end

    test "add_exemplars/2 with invalid data returns list of error changesets" do
      project = project_fixture()
      exemplar_ids = [1, 2, 3]
      errors = Projects.add_exemplars(project, exemplar_ids)

      Enum.each(errors, fn e ->
        assert {:error, %Ecto.Changeset{}} = e
      end)
    end

    test "add_exemplars/2 with valid data returns a list of ProjectExemplars" do
      project = project_fixture()
      exemplar = exemplar_fixture()

      Enum.each(Projects.add_exemplars(project, [exemplar.id]), fn pe ->
        assert {:ok, %ProjectExemplar{}} = pe
      end)
    end

    test "add_text_groups/2 with valid data returns a list of ProjectExemplars" do
      project = project_fixture()
      exemplars = [exemplar_fixture(), exemplar_fixture()]
      version_ids = exemplars |> Enum.map(fn e -> e.version_id end)

      work_ids =
        from(v in Version, where: v.id in ^version_ids, select: [:work_id])
        |> Repo.all()
        |> Enum.map(fn v -> v.work_id end)

      text_group_ids =
        from(w in Work, where: w.id in ^work_ids, select: [:text_group_id])
        |> Repo.all()
        |> Enum.map(fn w -> w.text_group_id end)

      Enum.each(Projects.add_text_groups(project, text_group_ids), fn pe ->
        assert {:ok, %ProjectExemplar{}} = pe
      end)
    end

    test "add_versions/2 with valid data returns a list of ProjectExemplars" do
      project = project_fixture()
      exemplars = [exemplar_fixture(), exemplar_fixture()]
      version_ids = exemplars |> Enum.map(fn e -> e.version_id end)

      Enum.each(Projects.add_versions(project, version_ids), fn pe ->
        assert {:ok, %ProjectExemplar{}} = pe
      end)
    end

    test "add_works/2 with valid data returns a list of ProjectExemplars" do
      project = project_fixture()
      exemplars = [exemplar_fixture(), exemplar_fixture()]
      version_ids = exemplars |> Enum.map(fn e -> e.version_id end)

      work_ids =
        from(v in Version, where: v.id in ^version_ids, select: [:work_id])
        |> Repo.all()
        |> Enum.map(fn v -> v.work_id end)

      Enum.each(Projects.add_works(project, work_ids), fn pe ->
        assert {:ok, %ProjectExemplar{}} = pe
      end)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()

      update_attrs = %{
        description: "some updated description",
        domain: "new-domain",
        title: "some updated title"
      }

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.description == "some updated description"
      assert project.domain == "new-domain"
      assert project.title == "some updated title"
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

  describe "Project.exemplars" do
    alias TextServer.Projects.Exemplar, as: ProjectExemplar

    import TextServer.ProjectsFixtures

    @invalid_attrs %{exemplar_id: "not a number", project_id: "not a number"}

    test "list_exemplars/0 returns all exemplars" do
      project_exemplar = project_exemplar_fixture()
      assert Projects.list_exemplars() == [project_exemplar]
    end

    test "get_exemplar!/1 returns the exemplar with given id" do
      project_exemplar = project_exemplar_fixture()
      assert Projects.get_exemplar!(project_exemplar.id) == project_exemplar
    end

    test "create_exemplar/1 with valid data creates a exemplar" do
      exemplar = TextServer.ExemplarsFixtures.exemplar_fixture()
      project = project_fixture()
      valid_attrs = %{exemplar_id: exemplar.id, project_id: project.id}

      assert {:ok, %ProjectExemplar{} = _project_exemplar} = Projects.create_exemplar(valid_attrs)
    end

    test "create_exemplar/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_exemplar(@invalid_attrs)
    end

    test "update_exemplar/2 with valid data updates the exemplar" do
      project_exemplar = project_exemplar_fixture()
      update_attrs = %{project_id: project_fixture().id}

      assert {:ok, %ProjectExemplar{} = _project_exemplar} =
               Projects.update_exemplar(project_exemplar, update_attrs)
    end

    test "update_exemplar/2 with invalid data returns error changeset" do
      project_exemplar = project_exemplar_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Projects.update_exemplar(project_exemplar, @invalid_attrs)

      assert project_exemplar == Projects.get_exemplar!(project_exemplar.id)
    end

    test "delete_exemplar/1 deletes the exemplar" do
      project_exemplar = project_exemplar_fixture()
      assert {:ok, %ProjectExemplar{}} = Projects.delete_exemplar(project_exemplar)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_exemplar!(project_exemplar.id) end
    end

    test "change_exemplar/1 returns a exemplar changeset" do
      project_exemplar = project_exemplar_fixture()
      assert %Ecto.Changeset{} = Projects.change_exemplar(project_exemplar)
    end
  end
end
