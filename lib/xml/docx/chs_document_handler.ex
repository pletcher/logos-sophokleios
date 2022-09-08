defmodule Xml.Docx.ChsDocumentHandler do
  @behaviour Saxy.Handler

  @moduledoc """
  In addition to capturing Microsoft's XML idiosyncrasies,
  this handler pays particular attention to CHS-specific styles.
  Notes about particular elements should be kept in this moduledoc
  for future reference.

  Unlike in CTS/TEI XML, there are no location identifiers in these XML
  documents. Instead, we need to rely on the stringified numbers inside curly
  braces (e.g., `{1.2.3}`) to spot TextNodes and store them accordingly.

  This creates a small problem in that we need to account for the string length of
  these characters when calculating the offset of TextElements within the
  TextNode.

  Elements:

  - w:footnote: Captures footnotes, generally in word/footnotes.xml.
  - w15:person: Captures a person involved in preparing the document. The attribute `w15:author` has the person's name. Found in word/people.xml.
  	- w15:presenceInfo: Child node of `w15:person` containing additional author information, such as `w15:userId`, which takes the form `S::$EMAIL::$UUID`. Thus `[_prefix, email, uuid] = String.split(user_id, "::")`.
  - w:t: Captures text. Contents should form the basic content of our TextNodes.
  - w:rStyle: Captures styles. Check `w:val` attribute for CHS-specific style names.
  - w:pStyle: Captures paragraph styles. Check `w:val` attribute for CHS-specific style names.
  """

  @location_regex ~r/\{\d{1,2}\.\d{1,2}\.\d{1,2}\}/

  def handle_event(:start_document, _prolog, state) do
    {:ok, Map.put(state, :location, [0])}
  end

  def handle_event(:end_document, _data, state) do
    {:ok, state}
  end

  def handle_event(:start_element, {name, attributes}, state),
    do: handle_element(name, attributes, state)

  def handle_event(:end_element, name, state) do
    text_elements = state[:text_elements]
    location = state[:location]
    offset = state[:offset]

    {:ok,
     Map.put(state, :text_elements, [
       %{tag_name: name, end: name, location: location, offset: offset} | text_elements
     ])}
  end

  def handle_event(:characters, chars, state) do
    if String.trim(chars) == "" do
      {:ok, state}
    else
      handle_chars(chars, state)
    end
  end

  def handle_event(:cdata, _cdata, state) do
    {:ok, state}
  end

  def handle_chars(chars, state) do
  	# It's possible for a node to be started before
  	# the location is parsed. We'll need to fix this
  	# for the first node
    location_marker = Regex.run(@location_regex, chars)

    current_location =
      if is_nil(location_marker) do
        state[:location]
      else
        parse_location_marker(location_marker)
      end

    IO.inspect(current_location)
    chars = String.replace(chars, @location_regex, "")

    chars =
      if is_nil(location_marker) do
        chars
      else
        String.trim_leading(chars)
      end

    current_els = state[:text_elements]

    existing_text_node_index =
      Enum.find_index(current_els, fn el ->
        Map.has_key?(el, :content) and el[:location] == current_location
      end)

    els =
      unless is_nil(existing_text_node_index) do
        # NOTE: (charles) We're not looking for the error case here because parsing
        # should fail if we can't find this node.
        {:ok, text_node} = Enum.fetch(current_els, existing_text_node_index)
        content = text_node[:content]

        List.replace_at(
          current_els,
          existing_text_node_index,
          Map.put(text_node, :content, content <> chars)
        )
      else
        [node | nodes] = current_els
        [Map.put(node, :content, chars) | nodes]
      end

    current_offset = Map.get(state, :offset, 0)

    new_state =
      state
      |> Map.put(:text_elements, els)
      |> Map.put(:offset, current_offset + String.length(chars))
      |> Map.put(:location, current_location)

    {:ok, new_state}
  end

  defp handle_element(name, attributes, state) do
    {:ok, prepend_element(state, name, attributes)}
  end

  defp parse_location_marker(regex_list) do
    List.first(regex_list)
    |> String.replace("{", "")
    |> String.replace("}", "")
    |> String.split(".")
    |> Enum.map(&String.to_integer/1)
  end

  defp prepend_element(state, name, attrs) do
    Map.put(state, :text_elements, [
      %{
        tag_name: name,
        start: name,
        attributes: Map.new(attrs),
        location: state[:location],
        offset: state[:offset]
      }
      | state[:text_elements]
    ])
  end
end
