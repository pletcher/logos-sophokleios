defmodule TextServer.TextNodesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.TextNodes` context.
  """

  @doc """
  Generate a text_node.
  """
  def version_text_node_fixture(version_id, attrs \\ %{}) do
    {:ok, text_node} =
      attrs
      |> Enum.into(%{
        version_id: version_id,
        location: [200, 1, 1],
        text: "some text"
      })
      |> TextServer.TextNodes.create_text_node()

    text_node
  end

  @doc """
  Generate a text_node.
  """
  def text_node_fixture(attrs \\ %{}) do
    version_id = Map.get(attrs, :version_id, version_fixture().id)

    {:ok, text_node} =
      attrs
      |> Enum.into(%{
        version_id: version_id,
        location: [100, 1, 1],
        text: "some text"
      })
      |> TextServer.TextNodes.create_text_node()

    text_node
  end

  defp version_fixture do
    TextServer.VersionsFixtures.text_node_version_fixture()
  end
end
