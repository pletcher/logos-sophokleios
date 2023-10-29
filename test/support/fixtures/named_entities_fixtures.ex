defmodule TextServer.NamedEntitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.NamedEntities` context.
  """

  def unique_named_entity_wikidata_id, do: "wikidata_id#{System.unique_integer([:positive])}"

  def named_entity_fixture(attrs \\ %{}) do
    {:ok, named_entity} =
      attrs
      |> Enum.into(%{
        label: "label",
        phrase: "phrase",
        wikidata_id: unique_named_entity_wikidata_id(),
        wikidata_description: "wikidata description"
      })
      |> TextServer.NamedEntities.create_named_entity()

    named_entity
  end

  def reference_fixture(named_entity, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        urn: "urn:cts:greekLit:tlg0525.tlg001.my-version:2.3.1@foo[1]-2.3.2@bar[2]",
        end_offset: 10,
        start_offset: 0
      })

    {:ok, reference} = TextServer.NamedEntities.create_named_entity_reference(named_entity, attrs)
    reference
  end
end
