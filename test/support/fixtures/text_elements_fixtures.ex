defmodule TextServer.TextElementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.TextElements` context.
  """

  @doc """
  Generate a text_element.
  """
  def text_element_fixture(attrs \\ %{}) do
    text_node = text_node_fixture()

    {:ok, text_element} =
      attrs
      |> Enum.into(%{
        attributes: %{},
        content: "Some content",
        start_offset: 1,
        end_offset: 5,
        element_type_id: element_type_fixture().id,
        start_text_node_id: text_node.id,
        end_text_node_id: text_node.id
      })
      |> TextServer.TextElements.create_text_element()

    text_element
  end

  defp element_type_fixture() do
    TextServer.ElementTypesFixtures.element_type_fixture()
  end

  defp text_node_fixture() do
    TextServer.TextNodesFixtures.text_node_fixture()
  end
end
