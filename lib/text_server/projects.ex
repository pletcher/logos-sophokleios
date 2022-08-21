defmodule TextServer.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Exemplars.Exemplar
  alias TextServer.Projects.Project
  alias TextServer.Projects.Exemplar, as: ProjectExemplar
  alias TextServer.Projects.User, as: ProjectUser
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

  @doc """
  Creates a project and assigns the passed-in user (generally
  the current_user) as an admin by creating a %ProjectUser{project_user_type: :admin}

  ## Examples

      iex> create_project(%User{}, %{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(user, attrs \\ %{}) do
  	Repo.transaction(fn repo ->
  		project = %Project{created_by_id: user.id}
  		|> Project.changeset(attrs)
  		|> repo.insert!()

  		project_user_attrs = %{
  			project_id: project.id,
  			project_user_type: :admin,
  			user_id: user.id
  		}

  		_project_user = %ProjectUser{}
  		|> ProjectUser.changeset(project_user_attrs)
  		|> repo.insert!()

  		project
  	end)
  end

  @doc """
  Fetches projects created by the given user.

  ## Examples

  		iex> created_by(%User{id: 1})
  		{:ok, [%Project{}]}
  """
  def created_by(user) do
  	from(p in Project, where: p.created_by_id == ^user.id)
  	|> Repo.all()
  end

  @doc """
  Adds all exemplars of a collection to a project. Returns list of ProjectExemplars.

  ## Examples

  		iex> add_work(project, 1)
  		[{:ok, %ProjectExemplar{}}, {:ok, %ProjectExemplar{}}]
  """
  def add_collection(project, collection_id) do
    text_group_ids =
      from(t in TextGroup, where: t.collection_id == ^collection_id, select: [:id])
      |> Repo.all()
      |> Enum.map(fn tg -> tg.id end)

    add_text_groups(project, text_group_ids)
  end

  @doc """
  Adds exemplars to a project.

  ## Examples

  		iex> add_exemplars(project, [1, 2])
  		[{:ok, %ProjectExemplar{}}, {:ok, %ProjectExemplar{}}]
  """
  def add_exemplars(project, exemplar_ids \\ []) do
    exemplar_ids
    |> Enum.map(fn ex_id ->
      %ProjectExemplar{}
      |> ProjectExemplar.changeset(%{
        project_id: project.id,
        exemplar_id: ex_id
      })
      |> Repo.insert()
    end)
  end

  @doc """
  Adds all exemplars of a text_group to a project. Returns list of ProjectExemplars.

  ## Examples

  		iex> add_work(project, [1])
  		[{:ok, %ProjectExemplar{}}, {:ok, %ProjectExemplar{}}]
  """
  def add_text_groups(project, text_group_ids) do
  	work_ids =
  	  from(w in Work, where: w.text_group_id in ^text_group_ids, select: [:id])
  	  |> Repo.all()
  	  |> Enum.map(fn w -> w.id end)

  	add_works(project, work_ids)
  end

  def add_versions(project, version_ids) do
  	exemplar_ids =
  		from(e in Exemplar, where: e.version_id in ^ version_ids, select: [:id])
  		|> Repo.all()
  		|> Enum.map(fn e -> e.id end)

  	add_exemplars(project, exemplar_ids)
  end

  @doc """
  Adds all exemplars of a work to a project. Returns list of ProjectExemplars.

  ## Examples

  		iex> add_work(project, 1)
  		[{:ok, %ProjectExemplar{}}, {:ok, %ProjectExemplar{}}]
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

  alias TextServer.Projects.Exemplar

  @doc """
  Returns the list of exemplars.

  ## Examples

      iex> list_exemplars()
      [%Exemplar{}, ...]

  """
  def list_exemplars do
    Repo.all(Exemplar)
  end

  @doc """
  Gets a single exemplar.

  Raises `Ecto.NoResultsError` if the Exemplar does not exist.

  ## Examples

      iex> get_exemplar!(123)
      %Exemplar{}

      iex> get_exemplar!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exemplar!(id), do: Repo.get!(Exemplar, id)

  @doc """
  Creates a exemplar.

  ## Examples

      iex> create_exemplar(%{field: value})
      {:ok, %Exemplar{}}

      iex> create_exemplar(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exemplar(attrs \\ %{}) do
    %Exemplar{}
    |> Exemplar.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exemplar.

  ## Examples

      iex> update_exemplar(exemplar, %{field: new_value})
      {:ok, %Exemplar{}}

      iex> update_exemplar(exemplar, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exemplar(%Exemplar{} = exemplar, attrs) do
    exemplar
    |> Exemplar.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a exemplar.

  ## Examples

      iex> delete_exemplar(exemplar)
      {:ok, %Exemplar{}}

      iex> delete_exemplar(exemplar)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exemplar(%Exemplar{} = exemplar) do
    Repo.delete(exemplar)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exemplar changes.

  ## Examples

      iex> change_exemplar(exemplar)
      %Ecto.Changeset{data: %Exemplar{}}

  """
  def change_exemplar(%Exemplar{} = exemplar, attrs \\ %{}) do
    Exemplar.changeset(exemplar, attrs)
  end
end
