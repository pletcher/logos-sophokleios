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
  - w:b: Captures bold text (inline style).
  - w:rStyle: Captures styles. Check `w:val` attribute for CHS-specific style names.
  - w:pStyle: Captures paragraph styles. Check `w:val` attribute for CHS-specific style names.
  - w:r: Short for "Run," which can contain pretty much any text --- see https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.run?view=openxml-2.8.1
  - w:rPr: "Run Properties" --- look for these tags inside of <w:r> --- for example:

  ```openxml
  <w:r w:rsidRPr="00DC4B78">
    <w:rPr>
      <w:i/>
      <w:iCs/>
    </w:rPr>
    <w:t>This</w:t>
  </w:r>
  ```

  in the above run, the Run Properties contain an "Italic" and "Italic Complex Script"
  tag. These apply to the text within the <w:t> tags.
  """

  @location_regex ~r/\{\d+\.\d+\.\d+\}/

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
       %{
         tag_name: name,
         end: name,
         location: location,
         offset: offset
       }
       | text_elements
     ])}
  end

  def handle_event(:characters, chars, state), do: handle_chars(chars, state)

  def handle_event(:cdata, _cdata, state) do
    {:ok, state}
  end

  def get_location(chars, state) do
    location_marker = Regex.run(@location_regex, chars)

    if is_nil(location_marker) do
      state[:location]
    else
      parse_location_marker(location_marker)
    end
  end

  def get_text(chars) do
    chars
    |> String.replace(@location_regex, "")
    |> String.trim()
  end

  def handle_chars(chars, state) do
    current_location = get_location(chars, state)
    text = get_text(chars)
    [node | nodes] = state[:text_nodes]

    new_node =
      Map.merge(node, %{
        location: current_location,
        text: node[:text] <> text
      })

    new_nodes = [new_node | nodes]

    new_state =
      state
      |> Map.merge(%{
        location: current_location,
        offset: Map.get(state, :offset, 0) + String.length(text),
        text_nodes: new_nodes
      })

    {:ok, new_state}
  end

  @doc """
  Parses an element and adds it to the appropriate
  list in `state`. The following elements are parsed
  (this list might grow):

  - <w:p>: a paragraph element. I think we can treat
  paragraphs as TextNodes.
  - <w:r>: a "run" element. Run elements in OpenOffice XML
  contain styling (w:rPr) and text (w:t)
  - <w:rPr>: a run styling element. These contain information
  about the styles that apply to a run, and should probably
  be stored as TextElements.
  - <w:t> a text element. These appear inside of runs.

  Elements that aren't handled here are just prepended
  to the `:text_elements` list in `state`.
  """
  def handle_element("w:p", attributes, state) do
    text_nodes = Map.get(state, :text_nodes, [])
    attr_map = Map.new(attributes)
    new_node = Map.merge(attr_map, %{text: ""})

    {:ok,
     state
     |> Map.merge(%{
       offset: 0,
       text_nodes: [new_node | text_nodes]
     })}
  end

  def handle_element("w:r", _attributes, state) do
    # not sure we need to do anything with runs yet
    {:ok, state}
  end

  def handle_element("w:rPr", _attributes, state) do
    {:ok, state}
  end

  def handle_element("w:t", attributes, state) do
    [node | nodes] = Map.get(state, :text_nodes)
    new_node = Map.merge(node, Map.new(attributes))
    {:ok, Map.put(state, :text_nodes, [new_node | nodes])}
  end

  def handle_element(name, attributes, state) do
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
