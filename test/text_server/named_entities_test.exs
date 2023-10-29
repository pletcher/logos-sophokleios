defmodule TextServer.NamedEntitiesTest do
  alias TextServer.NamedEntitiesFixtures
  alias TextServer.NamedEntities
  alias TextServer.NamedEntities.NamedEntity

  use TextServer.DataCase

  @valid_attrs %{
    label: "label",
    phrase: "phrase",
    wikidata_id: "wikidata_id",
    wikidata_description: "wikidata_description"
  }

  describe "named_entities" do
    test "create_named_entity/1 creates a NamedEntity" do
      assert {:ok, %NamedEntity{} = _named_entity} =
               NamedEntities.create_named_entity(@valid_attrs)
    end

    test "list_entities_for_urn/1 lists entities whose references match the given URN" do
      entity1 = NamedEntitiesFixtures.named_entity_fixture()
      entity2 = NamedEntitiesFixtures.named_entity_fixture()

      references = [
        NamedEntitiesFixtures.reference_fixture(entity1),
        NamedEntitiesFixtures.reference_fixture(entity2)
      ]

      reffed_entities = NamedEntities.list_entities_for_urn(List.first(references).urn)

      assert Enum.member?(reffed_entities, entity1)
      assert Enum.member?(reffed_entities, entity2)
    end
  end
end
