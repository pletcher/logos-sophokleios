defmodule Xml.VersionHeaderHandler do
  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _data, {_current_element, nodes}) do
    {:ok, nodes}
  end

  def handle_event(:start_element, {name, attributes}, state) do
    handle_element(name, attributes, state)
  end

  def handle_event(:end_element, "teiHeader", {_tags, nodes}) do
    {:stop, nodes}
  end

  def handle_event(:end_element, _name, state) do
    {:ok, state}
  end

  def handle_event(:characters, chars, {tags, nodes}) do
    cond do
      String.trim(chars) == "" ->
        # Whenever we get characters, pop off the first tag
        # Enum.drop/2 ensures that we don't throw an argument
        # error on an empty list
        {:ok, {Enum.drop(tags || [], 1), nodes}}

      tags == nil ->
        {:ok, {nil, nodes}}

      length(tags) == 0 ->
        {:ok, {tags, nodes}}

      true ->
        [tag | tags] = tags
        [node | nodes] = nodes

        el =
          node
          |> Map.put(:current_tag, tag)
          |> Map.put(:content, chars)
          |> Map.put(:tag_stack, tags)

        {:ok, {tags, [el | nodes]}}
    end
  end

  def handle_event(:cdata, cdata, state) do
    IO.inspect("Receive CData #{cdata}")
    {:ok, state}
  end

  defp handle_element("editionStmt", _attributes, {_tags, nodes}) do
    {:ok, {[:edition_statement], nodes}}
  end

  defp handle_element("encodingDesc", _attributes, {_tags, nodes}) do
    {:ok, {[:encoding_description], nodes}}
  end

  defp handle_element("profileDesc", _attributes, {_tags, nodes}) do
    {:ok, {[:profile_description], nodes}}
  end

  defp handle_element("publicationStmt", _attributes, {_tags, nodes}) do
    {:ok, {[:publication_statement], nodes}}
  end

  defp handle_element("respStmt", _attributes, {_tags, nodes}) do
    {:ok, {[:responsibility_statement], nodes}}
  end

  defp handle_element("revisionDesc", _attributes, {_tags, nodes}) do
    {:ok, {[:revision_description], nodes}}
  end

  defp handle_element("sourceDesc", _attributes, {_tags, nodes}) do
    {:ok, {[:source_description], nodes}}
  end

  defp handle_element("titleStmt", _attributes, {_tags, nodes}) do
    {:ok, {[:title_statement], nodes}}
  end

  defp handle_element("author", attributes, {tags, nodes}) do
    {:ok, {[:author | tags], [%{tag_name: "author", attributes: attributes} | nodes]}}
  end

  defp handle_element("authority", attributes, {tags, nodes}) do
    {:ok, {[:authority | tags], [%{tag_name: "authority", attributes: attributes} | nodes]}}
  end

  defp handle_element("change", attributes, {tags, nodes}) do
    {:ok, {[:change | tags], [%{tag_name: "change", attributes: attributes} | nodes]}}
  end

  defp handle_element("cRefPattern", attributes, {tags, nodes}) do
    {:ok, {[:cref_pattern | tags], [%{tag_name: "cRefPattern", attributes: attributes} | nodes]}}
  end

  defp handle_element("date", attributes, {tags, nodes}) do
    {:ok, {[:date | tags], [%{tag_name: "date", attributes: attributes} | nodes]}}
  end

  defp handle_element("editor", attributes, {tags, nodes}) do
    {:ok, {[:editor | tags], [%{tag_name: "editor", attributes: attributes} | nodes]}}
  end

  defp handle_element("funder", attributes, {tags, nodes}) do
    {:ok, {[:funder | tags], [%{tag_name: "funder", attributes: attributes} | nodes]}}
  end

  defp handle_element("language", attributes, {tags, nodes}) do
    {:ok, {[:language | tags], [%{tag_name: "language", attributes: attributes} | nodes]}}
  end

  defp handle_element("name", attributes, {tags, nodes}) do
    {:ok, {[:name | tags], [%{tag_name: "name", attributes: attributes} | nodes]}}
  end

  defp handle_element("principal", attributes, {tags, nodes}) do
    {:ok, {[:principal | tags], [%{tag_name: "principal", attributes: attributes} | nodes]}}
  end

  defp handle_element("publisher", attributes, {tags, nodes}) do
    {:ok, {[:publisher | tags], [%{tag_name: "publisher", attributes: attributes} | nodes]}}
  end

  defp handle_element("pubPlace", attributes, {tags, nodes}) do
    {:ok,
     {[:publication_place | tags], [%{tag_name: "pubPlace", attributes: attributes} | nodes]}}
  end

  defp handle_element("refState", attributes, {tags, nodes}) do
    {:ok, {[:ref_state | tags], [%{tag_name: "refState", attributes: attributes} | nodes]}}
  end

  defp handle_element("refsDecl", attributes, {tags, nodes}) do
    {:ok, {[:refs_decl | tags], [%{tag_name: "refsDecl", attributes: attributes} | nodes]}}
  end

  defp handle_element("resp", attributes, {tags, nodes}) do
    {:ok, {[:responsibility | tags], [%{tag_name: "resp", attributes: attributes} | nodes]}}
  end

  defp handle_element("sponsor", attributes, {tags, nodes}) do
    {:ok, {[:sponsor | tags], [%{tag_name: "sponsor", attributes: attributes} | nodes]}}
  end

  defp handle_element("title", attributes, {tags, nodes}) do
    {:ok, {[:title | tags], [%{tag_name: "title", attributes: attributes} | nodes]}}
  end

  defp handle_element(name, attributes, state) do
    IO.inspect("Not sure what to do with element #{name}. Attributes:")
    IO.inspect(attributes)
    {:ok, state}
  end
end
