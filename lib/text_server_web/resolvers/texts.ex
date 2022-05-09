defmodule TextServerWeb.Resolvers.Texts do
  def list_authors(_parent, _args, _resolution) do
    {:ok, TextServer.Texts.list_authors()}
  end

  def list_text_groups_in_collection(%TextServer.Texts.Collection{} = collection, args, _resolution) do
    {:ok, TextServer.Texts.list_text_groups_in_collection(collection, args)}
  end

  def list_text_groups(_parent, args, _resolution) do
    {:ok, TextServer.Texts.list_text_groups(args)}
  end
end
