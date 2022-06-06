defmodule TextServerWeb.Resolvers.Texts do
  def list_text_groups_in_collection(%TextServer.Collections.Collection{} = collection, args, _resolution) do
    {:ok, TextServer.Collections.list_text_groups_in_collection(collection, args)}
  end

  def list_text_groups(_parent, args, _resolution) do
    {:ok, TextServer.TextGroups.list_text_groups(args)}
  end
end
