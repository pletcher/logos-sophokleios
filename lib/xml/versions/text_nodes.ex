defmodule Xml.Versions.TextNodes do
  def text_node_fields(xpath) do
    [
      list_of: {:location, xpath, &{:ok, &1}},
      field: {:text, "#{xpath}/text()", &{:ok, &1}}
    ]
  end

  def text_nodes_fields(xpath) do
    [
      has_many: {:text_nodes, xpath, {%{}, text_node_fields(xpath)}}
    ]
  end
end
