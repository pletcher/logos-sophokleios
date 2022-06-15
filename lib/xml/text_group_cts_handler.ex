defmodule Xml.TextGroupCtsHandler do
  @behaviour Saxy.Handler

  def handle_event(:start_document, prolog, state) do
    IO.inspect("Start parsing document")
    {:ok, state}
  end

  def handle_event(:end_document, _data, state) do
    IO.inspect("Finish parsing document")
    {:ok, state}
  end

  def handle_event(:start_element, {name, attributes}, state) do
    {:ok, handle_element(name, attributes, state)}
  end

  def handle_event(:end_element, name, state) do
    IO.inspect("Finish parsing element #{name}")
    {:ok, state}
  end

  def handle_event(:characters, chars, %{waiting_for: waiting_for} = state) do
    {:ok, Map.delete(state, :waiting_for) |> Map.put(waiting_for, chars)}
  end

  def handle_event(:characters, chars, state) do
    {:ok, state}
  end

  def handle_event(:cdata, cdata, state) do
    IO.inspect("Receive CData #{cdata}")
    {:ok, state}
  end

  defp handle_element("groupname", attributes, state), do: handle_group_name(attributes, state)
  defp handle_element("textgroup", attributes, state), do: handle_text_group(attributes, state)
  defp handle_element("cts:groupname", attributes, state), do: handle_group_name(attributes, state)
  defp handle_element("cts:textgroup", attributes, state), do: handle_text_group(attributes, state)
  defp handle_element("ti:groupname", attributes, state), do: handle_group_name(attributes, state)
  defp handle_element("ti:textgroup", attributes, state), do: handle_text_group(attributes, state)

  defp handle_element(name, attributes, state) do
    IO.inspect("Received unknown element #{name}")
    state
  end

  defp handle_group_name(attributes, state) do
    language =
      try do
        lang_str = Enum.find(attributes, fn a -> elem(a, 0) == "xml:lang" end) |> elem(1)

        case lang_str do
          "ara" -> "arabic"
          "eng" -> "english"
          "heb" -> "hebrew"
          "san" -> "sanskrit"
          "ben" -> "bengali"
          "hin" -> "hindi"
          "enm" -> "middle_english"
          "lat" -> "latin"
          "non" -> "old_norse"
          "ang" -> "old_english"
          "zho" -> "chinese"
          "chi" -> "chinese"
          _ -> lang_str
        end
      rescue
        ArgumentError -> "english"
      end

    # NOTE: There can be multiple groupname elements in a single document. How
    # do we handle this?
    state |> Map.put(:language, language) |> Map.put(:waiting_for, :groupname)
  end

  defp handle_text_group(attributes, state) do
    urn = Enum.find(attributes, fn a -> elem(a, 0) == "urn" end) |> elem(1)

    state |> Map.put(:urn, urn)
  end
end
