defmodule TextServer.TextNodesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.TextNodes` context.
  """

  @doc """
  Generate a text_node.
  """
  def text_node_fixture(attrs \\ %{}) do
    {:ok, text_node} =
      
      if Map.get(attrs, :exemplar_id) do
        TextServer.TextNodes.create_text_node(%{
          index: 42,
          location: [1, 1],
          normalized_text: "some normalized_text",
          text: "some text",
          exemplar_id: Map.get(attrs, :exemplar_id)
        })
      else
        TextServer.TextNodes.create_text_node(%{
          index: 42,
          location: [1, 1],
          normalized_text: "some normalized_text",
          text: "some text",
          exemplar_id: exemplar_fixture().id
        })
      end
    text_node
  end

  defp exemplar_fixture do
    TextServer.ExemplarsFixtures.exemplar_fixture()
  end
end
