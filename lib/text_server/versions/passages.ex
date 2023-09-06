defmodule TextServer.Versions.Passages do
  @moduledoc """
  This module mainly exists to prevent the main context module
  from becoming too large.

  This module handles fetching passages for a given location
  in a version. In particular, it is useful for working out
  efficient ways to fetch from the XML documents.
  """

  alias TextServer.Versions.XmlDocuments
  alias TextServer.Versions.XmlDocuments.XmlDocument

  @doc """
  Returns a list of tuples representing possible passage references. The index + 1
  of a given tuple in the list corresponds to its "page" in the readable
  representation of the work.

  So, for example, for Pausanias, this function returns a list like

      [
        {"1", "1"},
        {"1", "2"},
        {"1", "3"},
        {"1", "4"},
        {"1", "5"},
        {"1", "6"},
        {"1", "7"},
        {"1", "8"},
        {"1", "9"},
        {"1", "10"},
        {"1", ...},
        {...},
        ...
      ]

  Page 1 is indicated by the 0th tuple, {"1", "1"}, which can be used to look up all
  of the passages for 1.1 in the table (map) of contents. Similarly,
  Page 5 is indicatd by the 4th tuple, {"1", "5"}, and can be used to look up
  all passages for 1.5 in the table of contents.
  """
  def list_passages(%XmlDocument{} = document) do
    {:ok, toc} = XmlDocuments.get_table_of_contents(document)

    passages =
      toc
      |> Enum.group_by(fn ref ->
        {elem(ref, 0), elem(ref, 1)}
      end)

    keys = Map.keys(passages)

    {:ok, Enum.sort_by(keys, &{String.to_integer(elem(&1, 0)), String.to_integer(elem(&1, 1))})}
  end
end
