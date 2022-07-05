defmodule Xml.ExemplarBodyHandler do
  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, state) do
    ref_levels = state[:ref_levels]

    {:ok,
     %{
       location: List.duplicate(0, Enum.count(ref_levels || ["substitute"])),
       offset: 0,
       text_elements: [],
       ref_levels: ref_levels
     }}
  end

  def handle_event(:end_document, _data, state) do
    {:ok, state}
  end

  def handle_event(:start_element, {name, attributes}, state) do
    elements = state[:text_elements]

    cond do
      not Enum.empty?(elements) ->
        handle_element(name, attributes, state)

      name == "text" ->
        handle_element(name, attributes, state)

      true ->
        {:ok, state}
    end
  end

  def handle_event(:end_element, name, state) do
    text_elements = state[:text_elements]

    if Enum.count(text_elements) == 0 do
      {:ok, state}
    else
      location = state[:location]
      offset = state[:offset]

      {:ok,
       Map.put(state, :text_elements, [
         %{tag_name: name, end: name, location: location, offset: offset} | text_elements
       ])}
    end
  end

  def handle_event(:end_element, _name, state), do: {:ok, state}

  def handle_event(:characters, chars, state) do
    cond do
      String.trim(chars) == "" ->
        {:ok, state}

      Enum.empty?(state[:text_elements]) ->
        {:ok, state}

      true ->
        [node | nodes] = state[:text_elements]

        current_position = Map.get(state, :offset, 0)

        new_state =
          state
          |> Map.put(:text_elements, [Map.put(node, :content, chars) | nodes])
          |> Map.put(:offset, current_position + String.length(chars))

        {:ok, new_state}
    end
  end

  def handle_event(:cdata, _cdata, state) do
    {:ok, state}
  end

  defp handle_element(name, attributes, state) do
    els = state[:text_elements]

    new_state = state |> set_location(name, attributes) |> set_element(name, attributes)

    {:ok, new_state}
  end

  defp set_element(state, name, attrs \\ []) do
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

  defp set_location(state, "bibl", _attrs), do: state

  defp set_location(state, name, attrs \\ []) do
    # We can zero out the position every time the location changes
    ref_levels = state[:ref_levels]
    attr_map = Map.new(attrs)
    n = Map.get(attr_map, "n")
    type = Map.get(attr_map, "type")
    subtype = Map.get(attr_map, "subtype")

    int =
      case Integer.parse(n || "0") do
        {i, _rem} -> i
        _ -> 0
      end

    new_state =
      cond do
        is_nil(ref_levels) ->
          state

        is_nil(n) ->
          state

        type == "textpart" ->
          idx = Enum.find_index(ref_levels, fn r -> r == subtype end)

          location =
            if is_nil(idx) do
              [int]
            else
              try do
                state[:location] |> List.replace_at(idx, int)
              rescue
                ArgumentError -> state[:location]
              end
            end

          Map.put(state, :location, location)

        Enum.count(attrs) == 1 ->
          Map.put(state, :location, [int])

        true ->
          state
      end

    if new_state[:location] == state[:location] do
      new_state
    else
      Map.put(new_state, :offset, 0)
    end
  end
end

# elements in <body>:
# div, p, milestone, term, add, l, lb, speaker, del, sp, quote
