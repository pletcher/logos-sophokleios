defmodule TextServerWeb.ReadLive.Collection do
  use TextServerWeb, :live_view

  alias TextServer.TextGroups

  def mount(%{"namespace" => namespace}, _session, socket) do
    {:ok, assign(socket, :text_groups, list_text_groups(namespace))}
  end

  def render(assigns) do
    ~H"""
    """
  end

  defp list_text_groups(namespace) do
    TextGroups.list_text_groups_for_namespace(namespace)
  end
end
