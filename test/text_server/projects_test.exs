defmodule TextServer.ProjectsTest do
  import Ecto.Query, warn: false
  use TextServer.DataCase

  alias TextServer.Projects
  alias TextServer.Repo

  alias TextServer.Projects.Project
  alias TextServer.Projects.Version, as: ProjectVersion
  alias TextServer.TextGroups.TextGroup
  alias TextServer.Versions.Version
  alias TextServer.Works.Work

  import TextServer.AccountsFixtures
  import TextServer.VersionsFixtures
  import TextServer.ProjectsFixtures

  @invalid_attrs %{
    created_by_id: nil,
    description: nil,
    domain: "some domain",
    homepage_copy: "# Markdown",
    title: nil
  }

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

      assert %Ecto.InvalidChangesetError{} =
               catch_error(Projects.create_project(bad_domain_attrs))
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

    test "add_collection/2 with valid data returns a list of ProjectVersions" do
      project = project_fixture()
      versions = [version_fixture(), version_fixture()]
      version_ids = versions |> Enum.map(fn v -> v.id end)

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
          assert {:ok, %ProjectVersion{}} = pe
        end)
      end)
    end

    test "add_versions/2 with invalid data returns list of error changesets" do
      project = project_fixture()
      version_ids = [1, 2, 3]
      errors = Projects.add_versions(project, version_ids)

      Enum.each(errors, fn e ->
        assert {:error, %Ecto.Changeset{}} = e
      end)
    end

    test "add_versions/2 with valid data returns a list of ProjectVersions" do
      project = project_fixture()
      version = version_fixture()

      Enum.each(Projects.add_versions(project, [version.id]), fn pv ->
        assert {:ok, %ProjectVersion{}} = pv
      end)
    end

    test "add_text_groups/2 with valid data returns a list of ProjectVersions" do
      project = project_fixture()
      versions = [version_fixture(), version_fixture()]
      version_ids = versions |> Enum.map(fn v -> v.id end)

      work_ids =
        from(v in Version, where: v.id in ^version_ids, select: [:work_id])
        |> Repo.all()
        |> Enum.map(fn v -> v.work_id end)

      text_group_ids =
        from(w in Work, where: w.id in ^work_ids, select: [:text_group_id])
        |> Repo.all()
        |> Enum.map(fn w -> w.text_group_id end)

      Enum.each(Projects.add_text_groups(project, text_group_ids), fn pv ->
        assert {:ok, %ProjectVersion{}} = pv
      end)
    end

    test "add_works/2 with valid data returns a list of ProjectVersions" do
      project = project_fixture()
      versions = [version_fixture(), version_fixture()]
      version_ids = versions |> Enum.map(fn e -> e.id end)

      work_ids =
        from(v in Version, where: v.id in ^version_ids, select: [:work_id])
        |> Repo.all()
        |> Enum.map(fn v -> v.work_id end)

      Enum.each(Projects.add_works(project, work_ids), fn pv ->
        assert {:ok, %ProjectVersion{}} = pv
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

  describe "Project.versions" do
    alias TextServer.Projects.Version, as: ProjectVersion

    import TextServer.ProjectsFixtures

    @invalid_attrs %{version_id: "not a number", project_id: "not a number"}

    test "list_versions/0 returns all versions" do
      project_version = project_version_fixture()
      assert Projects.list_versions() == [project_version]
    end

    test "get_version!/1 returns the version with given id" do
      project_version = project_version_fixture()
      assert Projects.get_version!(project_version.id) == project_version
    end

    test "create_version/1 with valid data creates a version" do
      version = TextServer.VersionsFixtures.version_fixture()
      project = project_fixture()
      valid_attrs = %{version_id: version.id, project_id: project.id}

      assert {:ok, %ProjectVersion{} = _project_version} = Projects.create_version(valid_attrs)
    end

    test "create_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_version(@invalid_attrs)
    end

    test "update_version/2 with valid data updates the version" do
      project_version = project_version_fixture()
      update_attrs = %{project_id: project_fixture().id}

      assert {:ok, %ProjectVersion{} = _project_version} =
               Projects.update_version(project_version, update_attrs)
    end

    test "update_version/2 with invalid data returns error changeset" do
      project_version = project_version_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Projects.update_version(project_version, @invalid_attrs)

      assert project_version == Projects.get_version!(project_version.id)
    end

    test "delete_version/1 deletes the version" do
      project_version = project_version_fixture()
      assert {:ok, %ProjectVersion{}} = Projects.delete_version(project_version)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_version!(project_version.id) end
    end

    test "change_version/1 returns a version changeset" do
      project_version = project_version_fixture()
      assert %Ecto.Changeset{} = Projects.change_version(project_version)
    end
  end
end
