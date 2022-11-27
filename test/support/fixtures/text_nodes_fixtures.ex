defmodule TextServer.TextNodesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.TextNodes` context.
  """

  @doc """
  Generate a text_node.
  """
  def exemplar_text_node_fixture(exemplar_id, attrs \\ %{}) do
    {:ok, text_node} =
      attrs
      |> Enum.into(%{
        exemplar_id: exemplar_id,
        location: [1, 1, 1],
        text: "some text"
      })
      |> TextServer.TextNodes.create_text_node()

    text_node
  end

  @doc """
  Generate a text_node.
  """
  def text_node_fixture(attrs \\ %{}) do
    exemplar_id = Map.get(attrs, :exemplar_id, exemplar_fixture().id)

    {:ok, text_node} =
      attrs
      |> Enum.into(%{
        exemplar_id: exemplar_id,
        location: [1, 1, 1],
        text: "some text"
      })
      |> TextServer.TextNodes.create_text_node()

    text_node
  end

  defp exemplar_fixture do
    TextServer.ExemplarsFixtures.text_node_exemplar_fixture()
  end
end
