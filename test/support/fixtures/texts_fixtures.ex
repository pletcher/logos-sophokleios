defmodule TextServer.TextsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Texts` context.
  """

  @doc """
  Generate a author.
  """
  def author_fixture(attrs \\ %{}) do
    {:ok, author} =
      attrs
      |> Enum.into(%{
        english_name: "some english_name",
        original_name: "some original_name",
        slug: "some slug"
      })
      |> TextServer.Texts.create_author()

    author
  end

  @doc """
  Generate a collection.
  """
  def collection_fixture(attrs \\ %{}) do
    {:ok, collection} =
      attrs
      |> Enum.into(%{

      })
      |> TextServer.Texts.create_collection()

    collection
  end

  @doc """
  Generate a exemplar.
  """
  def exemplar_fixture(attrs \\ %{}) do
    {:ok, exemplar} =
      attrs
      |> Enum.into(%{
        description: "some description",
        slug: "some slug",
        title: "some title",
        urn: "some urn"
      })
      |> TextServer.Texts.create_exemplar()

    exemplar
  end

  @doc """
  Generate a language.
  """
  def language_fixture(attrs \\ %{}) do
    {:ok, language} =
      attrs
      |> Enum.into(%{
        slug: "some slug",
        title: "some title"
      })
      |> TextServer.Texts.create_language()

    language
  end

  @doc """
  Generate a refs_decl.
  """
  def refs_decl_fixture(attrs \\ %{}) do
    {:ok, refs_decl} =
      attrs
      |> Enum.into(%{
        description: "some description",
        label: "some label",
        match_pattern: "some match_pattern",
        replacement_pattern: "some replacement_pattern",
        slug: "some slug",
        structure_index: 42,
        urn: "some urn"
      })
      |> TextServer.Texts.create_refs_decl()

    refs_decl
  end

  @doc """
  Generate a text_group.
  """
  def text_group_fixture(attrs \\ %{}) do
    {:ok, text_group} =
      attrs
      |> Enum.into(%{
        slug: "some slug",
        title: "some title",
        urn: "some urn"
      })
      |> TextServer.Texts.create_text_group()

    text_group
  end

  @doc """
  Generate a text_node.
  """
  def text_node_fixture(attrs \\ %{}) do
    {:ok, text_node} =
      attrs
      |> Enum.into(%{
        index: 42,
        location: [],
        normalized_text: "some normalized_text",
        text: "some text"
      })
      |> TextServer.Texts.create_text_node()

    text_node
  end

  @doc """
  Generate a translation.
  """
  def translation_fixture(attrs \\ %{}) do
    {:ok, translation} =
      attrs
      |> Enum.into(%{
        description: "some description",
        slug: "some slug",
        title: "some title",
        urn: "some urn"
      })
      |> TextServer.Texts.create_translation()

    translation
  end

  @doc """
  Generate a version.
  """
  def version_fixture(attrs \\ %{}) do
    {:ok, version} =
      attrs
      |> Enum.into(%{
        description: "some description",
        slug: "some slug",
        title: "some title",
        urn: "some urn"
      })
      |> TextServer.Texts.create_version()

    version
  end

  @doc """
  Generate a work.
  """
  def work_fixture(attrs \\ %{}) do
    {:ok, work} =
      attrs
      |> Enum.into(%{
        description: "some description",
        english_title: "some english_title",
        filemd5hash: "some filemd5hash",
        filename: "some filename",
        form: "some form",
        full_urn: "some full_urn",
        label: "some label",
        original_title: "some original_title",
        slug: "some slug",
        structure: "some structure",
        urn: "some urn",
        work_type: "some work_type"
      })
      |> TextServer.Texts.create_work()

    work
  end
end
