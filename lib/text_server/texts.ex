defmodule TextServer.Texts do
  @moduledoc """
  The Texts context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Texts.Author

  @doc """
  Returns the list of authors.

  ## Examples

      iex> list_authors()
      [%Author{}, ...]

  """
  def list_authors do
    Repo.all(Author)
  end

  @doc """
  Gets a single author.

  Raises `Ecto.NoResultsError` if the Author does not exist.

  ## Examples

      iex> get_author!(123)
      %Author{}

      iex> get_author!(456)
      ** (Ecto.NoResultsError)

  """
  def get_author!(id), do: Repo.get!(Author, id)

  @doc """
  Creates a author.

  ## Examples

      iex> create_author(%{field: value})
      {:ok, %Author{}}

      iex> create_author(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a author.

  ## Examples

      iex> update_author(author, %{field: new_value})
      {:ok, %Author{}}

      iex> update_author(author, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a author.

  ## Examples

      iex> delete_author(author)
      {:ok, %Author{}}

      iex> delete_author(author)
      {:error, %Ecto.Changeset{}}

  """
  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking author changes.

  ## Examples

      iex> change_author(author)
      %Ecto.Changeset{data: %Author{}}

  """
  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end

  alias TextServer.Texts.Collection

  @doc """
  Returns the list of collections.

  ## Examples

      iex> list_collections()
      [%Collection{}, ...]

  """
  def list_collections do
    Repo.all(Collection)
  end

  @doc """
  Gets a single collection.

  Raises `Ecto.NoResultsError` if the Collection does not exist.

  ## Examples

      iex> get_collection!(123)
      %Collection{}

      iex> get_collection!(456)
      ** (Ecto.NoResultsError)

  """
  def get_collection!(id), do: Repo.get!(Collection, id)

  @doc """
  Creates a collection.

  ## Examples

      iex> create_collection(%{field: value})
      {:ok, %Collection{}}

      iex> create_collection(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_collection(attrs \\ %{}) do
    %Collection{}
    |> Collection.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a collection.

  ## Examples

      iex> update_collection(collection, %{field: new_value})
      {:ok, %Collection{}}

      iex> update_collection(collection, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a collection.

  ## Examples

      iex> delete_collection(collection)
      {:ok, %Collection{}}

      iex> delete_collection(collection)
      {:error, %Ecto.Changeset{}}

  """
  def delete_collection(%Collection{} = collection) do
    Repo.delete(collection)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collection changes.

  ## Examples

      iex> change_collection(collection)
      %Ecto.Changeset{data: %Collection{}}

  """
  def change_collection(%Collection{} = collection, attrs \\ %{}) do
    Collection.changeset(collection, attrs)
  end

  alias TextServer.Texts.Exemplar

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

  alias TextServer.Texts.Language

  @doc """
  Returns the list of languages.

  ## Examples

      iex> list_languages()
      [%Language{}, ...]

  """
  def list_languages do
    Repo.all(Language)
  end

  @doc """
  Gets a single language.

  Raises `Ecto.NoResultsError` if the Language does not exist.

  ## Examples

      iex> get_language!(123)
      %Language{}

      iex> get_language!(456)
      ** (Ecto.NoResultsError)

  """
  def get_language!(id), do: Repo.get!(Language, id)

  @doc """
  Creates a language.

  ## Examples

      iex> create_language(%{field: value})
      {:ok, %Language{}}

      iex> create_language(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_language(attrs \\ %{}) do
    %Language{}
    |> Language.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a language.

  ## Examples

      iex> update_language(language, %{field: new_value})
      {:ok, %Language{}}

      iex> update_language(language, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_language(%Language{} = language, attrs) do
    language
    |> Language.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a language.

  ## Examples

      iex> delete_language(language)
      {:ok, %Language{}}

      iex> delete_language(language)
      {:error, %Ecto.Changeset{}}

  """
  def delete_language(%Language{} = language) do
    Repo.delete(language)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking language changes.

  ## Examples

      iex> change_language(language)
      %Ecto.Changeset{data: %Language{}}

  """
  def change_language(%Language{} = language, attrs \\ %{}) do
    Language.changeset(language, attrs)
  end

  alias TextServer.Texts.RefsDecl

  @doc """
  Returns the list of refs_decls.

  ## Examples

      iex> list_refs_decls()
      [%RefsDecl{}, ...]

  """
  def list_refs_decls do
    Repo.all(RefsDecl)
  end

  @doc """
  Gets a single refs_decl.

  Raises `Ecto.NoResultsError` if the Refs decl does not exist.

  ## Examples

      iex> get_refs_decl!(123)
      %RefsDecl{}

      iex> get_refs_decl!(456)
      ** (Ecto.NoResultsError)

  """
  def get_refs_decl!(id), do: Repo.get!(RefsDecl, id)

  @doc """
  Creates a refs_decl.

  ## Examples

      iex> create_refs_decl(%{field: value})
      {:ok, %RefsDecl{}}

      iex> create_refs_decl(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_refs_decl(attrs \\ %{}) do
    %RefsDecl{}
    |> RefsDecl.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a refs_decl.

  ## Examples

      iex> update_refs_decl(refs_decl, %{field: new_value})
      {:ok, %RefsDecl{}}

      iex> update_refs_decl(refs_decl, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_refs_decl(%RefsDecl{} = refs_decl, attrs) do
    refs_decl
    |> RefsDecl.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a refs_decl.

  ## Examples

      iex> delete_refs_decl(refs_decl)
      {:ok, %RefsDecl{}}

      iex> delete_refs_decl(refs_decl)
      {:error, %Ecto.Changeset{}}

  """
  def delete_refs_decl(%RefsDecl{} = refs_decl) do
    Repo.delete(refs_decl)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking refs_decl changes.

  ## Examples

      iex> change_refs_decl(refs_decl)
      %Ecto.Changeset{data: %RefsDecl{}}

  """
  def change_refs_decl(%RefsDecl{} = refs_decl, attrs \\ %{}) do
    RefsDecl.changeset(refs_decl, attrs)
  end

  alias TextServer.Texts.TextGroup

  @doc """
  Returns the list of text_groups.

  ## Examples

      iex> list_text_groups()
      [%TextGroup{}, ...]

  """
  def list_text_groups(attrs \\ %{}) do
    TextGroup
    |> where(^filter_text_group_where(attrs))
    |> limit(^limit_text_group(attrs))
    |> offset(^offset_text_group(attrs))
    |> Repo.all
  end

  def list_text_groups_in_collection(%Collection{} = collection, attrs \\ %{}) do
    TextGroup
    |> where([t], t.collection_id == ^collection.id)
    |> where(^filter_text_group_where(attrs))
    |> limit(^limit_text_group(attrs))
    |> offset(^offset_text_group(attrs))
    |> Repo.all
  end

  def limit_text_group({"limit", value}), do: value

  def limit_text_group(_), do: 20

  def offset_text_group({"offset", value}), do: value

  def offset_text_group(_), do: 0

  def filter_text_group_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"urn", value}, dynamic ->
        dynamic([tg], ^dynamic and tg.urn == ^value)

      {"textsearch", value}, dynamic ->
        dynamic([tg], ^dynamic and ilike(tg.textsearch, fragment("%?%", ^value)))

      {_, _}, dynamic ->
        dynamic
    end)
  end

  @doc """
  Gets a single text_group.

  Raises `Ecto.NoResultsError` if the Text group does not exist.

  ## Examples

      iex> get_text_group!(123)
      %TextGroup{}

      iex> get_text_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_text_group!(id), do: Repo.get!(TextGroup, id)

  @doc """
  Creates a text_group.

  ## Examples

      iex> create_text_group(%{field: value})
      {:ok, %TextGroup{}}

      iex> create_text_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_text_group(attrs \\ %{}) do
    %TextGroup{}
    |> TextGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a text_group.

  ## Examples

      iex> update_text_group(text_group, %{field: new_value})
      {:ok, %TextGroup{}}

      iex> update_text_group(text_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_text_group(%TextGroup{} = text_group, attrs) do
    text_group
    |> TextGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a text_group.

  ## Examples

      iex> delete_text_group(text_group)
      {:ok, %TextGroup{}}

      iex> delete_text_group(text_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_text_group(%TextGroup{} = text_group) do
    Repo.delete(text_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking text_group changes.

  ## Examples

      iex> change_text_group(text_group)
      %Ecto.Changeset{data: %TextGroup{}}

  """
  def change_text_group(%TextGroup{} = text_group, attrs \\ %{}) do
    TextGroup.changeset(text_group, attrs)
  end

  alias TextServer.Texts.TextNode

  @doc """
  Returns the list of text_nodes.

  ## Examples

      iex> list_text_nodes()
      [%TextNode{}, ...]

  """
  def list_text_nodes do
    Repo.all(TextNode)
  end

  @doc """
  Gets a single text_node.

  Raises `Ecto.NoResultsError` if the Text node does not exist.

  ## Examples

      iex> get_text_node!(123)
      %TextNode{}

      iex> get_text_node!(456)
      ** (Ecto.NoResultsError)

  """
  def get_text_node!(id), do: Repo.get!(TextNode, id)

  @doc """
  Creates a text_node.

  ## Examples

      iex> create_text_node(%{field: value})
      {:ok, %TextNode{}}

      iex> create_text_node(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_text_node(attrs \\ %{}) do
    %TextNode{}
    |> TextNode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a text_node.

  ## Examples

      iex> update_text_node(text_node, %{field: new_value})
      {:ok, %TextNode{}}

      iex> update_text_node(text_node, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_text_node(%TextNode{} = text_node, attrs) do
    text_node
    |> TextNode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a text_node.

  ## Examples

      iex> delete_text_node(text_node)
      {:ok, %TextNode{}}

      iex> delete_text_node(text_node)
      {:error, %Ecto.Changeset{}}

  """
  def delete_text_node(%TextNode{} = text_node) do
    Repo.delete(text_node)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking text_node changes.

  ## Examples

      iex> change_text_node(text_node)
      %Ecto.Changeset{data: %TextNode{}}

  """
  def change_text_node(%TextNode{} = text_node, attrs \\ %{}) do
    TextNode.changeset(text_node, attrs)
  end

  alias TextServer.Texts.Translation

  @doc """
  Returns the list of translations.

  ## Examples

      iex> list_translations()
      [%Translation{}, ...]

  """
  def list_translations do
    Repo.all(Translation)
  end

  @doc """
  Gets a single translation.

  Raises `Ecto.NoResultsError` if the Translation does not exist.

  ## Examples

      iex> get_translation!(123)
      %Translation{}

      iex> get_translation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_translation!(id), do: Repo.get!(Translation, id)

  @doc """
  Creates a translation.

  ## Examples

      iex> create_translation(%{field: value})
      {:ok, %Translation{}}

      iex> create_translation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_translation(attrs \\ %{}) do
    %Translation{}
    |> Translation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a translation.

  ## Examples

      iex> update_translation(translation, %{field: new_value})
      {:ok, %Translation{}}

      iex> update_translation(translation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_translation(%Translation{} = translation, attrs) do
    translation
    |> Translation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a translation.

  ## Examples

      iex> delete_translation(translation)
      {:ok, %Translation{}}

      iex> delete_translation(translation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_translation(%Translation{} = translation) do
    Repo.delete(translation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking translation changes.

  ## Examples

      iex> change_translation(translation)
      %Ecto.Changeset{data: %Translation{}}

  """
  def change_translation(%Translation{} = translation, attrs \\ %{}) do
    Translation.changeset(translation, attrs)
  end

  alias TextServer.Texts.Version

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

  alias TextServer.Texts.Work

  @doc """
  Returns the list of works.

  ## Examples

      iex> list_works()
      [%Work{}, ...]

  """
  def list_works do
    Repo.all(Work)
  end

  @doc """
  Gets a single work.

  Raises `Ecto.NoResultsError` if the Work does not exist.

  ## Examples

      iex> get_work!(123)
      %Work{}

      iex> get_work!(456)
      ** (Ecto.NoResultsError)

  """
  def get_work!(id), do: Repo.get!(Work, id)

  @doc """
  Creates a work.

  ## Examples

      iex> create_work(%{field: value})
      {:ok, %Work{}}

      iex> create_work(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work(attrs \\ %{}) do
    %Work{}
    |> Work.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a work.

  ## Examples

      iex> update_work(work, %{field: new_value})
      {:ok, %Work{}}

      iex> update_work(work, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work(%Work{} = work, attrs) do
    work
    |> Work.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a work.

  ## Examples

      iex> delete_work(work)
      {:ok, %Work{}}

      iex> delete_work(work)
      {:error, %Ecto.Changeset{}}

  """
  def delete_work(%Work{} = work) do
    Repo.delete(work)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking work changes.

  ## Examples

      iex> change_work(work)
      %Ecto.Changeset{data: %Work{}}

  """
  def change_work(%Work{} = work, attrs \\ %{}) do
    Work.changeset(work, attrs)
  end
end
