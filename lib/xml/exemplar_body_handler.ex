defmodule Xml.ExemplarBodyHandler do
  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, %{ref_levels: ref_levels} = _state) do
    {:ok,
     %{
       ref_levels: ref_levels,
       text_elements: [],
       location: Tuple.duplicate(0, Enum.count(ref_levels || ["substitute"]))
     }}
  end

  def handle_event(:end_document, _data, state) do
    {:ok, state}
  end

  def handle_event(
        :start_element,
        {name, attributes},
        %{
          text_elements: elements
        } = state
      ) do
    cond do
      not Enum.empty?(elements) ->
        handle_element(name, attributes, state)

      name == "text" ->
        handle_element(name, attributes, state)

      true ->
        {:ok, state}
    end
  end

  def handle_event(
        :end_element,
        name,
        %{location: location, text_elements: text_elements} = state
      ) do
    if Enum.empty?(text_elements) do
      {:ok, state}
    else
      {:ok, Map.put(state, :text_elements, [%{end: name, location: location} | text_elements])}
    end
  end

  def handle_event(:characters, chars, state) do
    cond do
      String.trim(chars) == "" ->
        {:ok, state}

      Enum.empty?(state[:text_elements]) ->
        {:ok, state}

      true ->
        [node | nodes] = state[:text_elements]

        {:ok, Map.put(state, :text_elements, [Map.put(node, :content, chars) | nodes])}
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
      %{tag_name: name, attributes: Map.new(attrs), location: state[:location]}
      | state[:text_elements]
    ])
  end

  defp set_location(state, "bibl", _attrs), do: state

  defp set_location(state, name, attrs \\ []) do
    ref_levels = state[:ref_levels]
    attr_map = Map.new(attrs)
    n = Map.get(attr_map, "n")
    type = Map.get(attr_map, "type")
    subtype = Map.get(attr_map, "subtype")

    cond do
      is_nil(ref_levels) ->
        state

      is_nil(n) ->
        state

      type == "textpart" ->
        idx = Enum.find_index(ref_levels, fn r -> r == subtype end)

        unless is_nil(idx) do
          i =
            case Integer.parse(n) do
              :error -> 0
              {int, _rem} -> int
              _ -> 0
            end

          new_location =
            try do
              state[:location] |> put_elem(idx, i)
            rescue
              ArgumentError -> state[:location]
            end

          Map.put(state, :location, new_location)
        else
          i = Integer.parse(n)

          if i == :error do
            Map.put(state, :location, {0})
          else
            Map.put(state, :location, {i})
          end
        end

      n && Enum.count(attrs) == 1 ->
        Map.put(state, :location, {Integer.parse(n)})

      true ->
        state
    end
  end
end

# elements in <body>:
# div, p, milestone, term, add, l, lb, speaker, del, sp, quote
