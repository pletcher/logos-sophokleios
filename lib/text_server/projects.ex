defmodule TextServer.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Projects.Project
  alias TextServer.Projects.User, as: ProjectUser
  alias TextServer.Projects.Version, as: ProjectVersion
  alias TextServer.TextGroups.TextGroup
  alias TextServer.Versions.Version
  alias TextServer.Works.Work

  @doc """
  Returns the list of project.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @spec get_project!(integer()) :: any
  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  def get_project_by_domain!(domain) do
    d = if Mix.env() == :dev do
      domain |> String.replace_suffix(".local", "")
    else
      domain
    end

    query = from(p in Project, where: p.domain == ^d)

    Repo.one!(query)
  end

  def get_project_with_versions(id) do
    Project
    |> preload(:project_versions)
    |> Repo.get(id)
  end

  def get_project_versions(id) do
    q = from(pe in ProjectVersion, where: pe.project_id == ^id, preload: :version)

    Repo.all(q) |> Enum.map(fn pe -> pe.version end)
  end

  @doc """
  Creates a project and assigns the user identified by
  attrs["created_by_id"] as an admin by creating a %ProjectUser{project_user_type: :admin}

  ## Examples

      iex> create_project(%User{}, %{field: value})
      {:ok, %Project{}}

      iex> create_project(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs) do
    Repo.transaction(fn repo ->
      project =
        %Project{}
        |> Project.changeset(attrs)
        |> repo.insert!()

      project_user_attrs = %{
        project_id: project.id,
        project_user_type: :admin,
        user_id: project.created_by_id
      }

      _project_user =
        %ProjectUser{}
        |> ProjectUser.changeset(project_user_attrs)
        |> repo.insert!()

      project
    end)
  end

  def create_project_version(project, version) do
    %ProjectVersion{}
    |> ProjectVersion.changeset(%{project_id: project.id, version_id: version.id})
    |> Repo.insert()
  end

  @doc """
  Fetches projects created by the given user.

  ## Examples

  		iex> list_projects_created_by(%User{id: 1})
  		{:ok, [%Project{}]}
  """
  def list_projects_created_by(user) do
    from(p in Project, where: p.created_by_id == ^user.id)
    |> Repo.all()
  end

  @doc """
  Adds all versions of a collection to a project. Returns list of ProjectVersions.

  ## Examples

  		iex> add_work(project, 1)
  		[{:ok, %ProjectVersion{}}, {:ok, %ProjectVersion{}}]
  """
  def add_collection(project, collection_id) do
    text_group_ids =
      from(t in TextGroup, where: t.collection_id == ^collection_id, select: [:id])
      |> Repo.all()
      |> Enum.map(fn tg -> tg.id end)

    add_text_groups(project, text_group_ids)
  end

  @doc """
  Adds versions to a project.

  ## Examples

  		iex> add_versions(project, [1, 2])
  		[{:ok, %ProjectVersion{}}, {:ok, %ProjectVersion{}}]
  """
  def add_versions(project, version_ids \\ []) do
    version_ids
    |> Enum.map(fn ex_id ->
      %ProjectVersion{}
      |> ProjectVersion.changeset(%{
        project_id: project.id,
        version_id: ex_id
      })
      |> Repo.insert()
    end)
  end

  @doc """
  Adds all versions of a text_group to a project. Returns list of ProjectVersions.

  ## Examples

  		iex> add_work(project, [1])
  		[{:ok, %ProjectVersion{}}, {:ok, %ProjectVersion{}}]
  """
  def add_text_groups(project, text_group_ids) do
    work_ids =
      from(w in Work, where: w.text_group_id in ^text_group_ids, select: [:id])
      |> Repo.all()
      |> Enum.map(fn w -> w.id end)

    add_works(project, work_ids)
  end

  @doc """
  Adds all versions of a work to a project. Returns list of ProjectVersions.

  ## Examples

  		iex> add_work(project, 1)
  		[{:ok, %ProjectVersion{}}, {:ok, %ProjectVersion{}}]
  """
  def add_works(project, work_ids) do
    version_ids =
      from(v in Version, where: v.work_id in ^work_ids, select: [:id])
      |> Repo.all()
      |> Enum.map(fn v -> v.id end)

    add_versions(project, version_ids)
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  alias TextServer.Projects.Version

  @doc """
  Returns the list of versions.

  ## Examples

      iex> list_versions()
      [%Version{}, ...]

  """
  def list_versions do
    Repo.all(Version)
  end

  @doc """
  Gets a single version.

  Raises `Ecto.NoResultsError` if the Version does not exist.

  ## Examples

      iex> get_version!(123)
      %Version{}

      iex> get_version!(456)
      ** (Ecto.NoResultsError)

  """
  def get_version!(id), do: Repo.get!(Version, id)

  @doc """
  Creates a version.

  ## Examples

      iex> create_version(%{field: value})
      {:ok, %Version{}}

      iex> create_version(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_version(attrs \\ %{}) do
    %Version{}
    |> Version.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a version.

  ## Examples

      iex> update_version(version, %{field: new_value})
      {:ok, %Version{}}

      iex> update_version(version, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_version(%Version{} = version, attrs) do
    version
    |> Version.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a version.

  ## Examples

      iex> delete_version(version)
      {:ok, %Version{}}

      iex> delete_version(version)
      {:error, %Ecto.Changeset{}}

  """
  def delete_version(%Version{} = version) do
    Repo.delete(version)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking version changes.

  ## Examples

      iex> change_version(version)
      %Ecto.Changeset{data: %Version{}}

  """
  def change_version(%Version{} = version, attrs \\ %{}) do
    Version.changeset(version, attrs)
  end

  @doc """
  Returns true if `user` is an `admin` of the given `project`; false otherwise.
  """

  def is_user_admin?(%Project{} = project, %TextServer.Accounts.User{} = user) do
    project_user =
      from(p in ProjectUser, where: p.project_id == ^project.id and p.user_id == ^user.id)
      |> Repo.one()

    project_user.project_user_type == :admin
  end
end
