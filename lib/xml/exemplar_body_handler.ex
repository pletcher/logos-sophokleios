defmodule Xml.ExemplarBodyHandler do
  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, _state) do
    {:ok, %{current_tag: nil, text_elements: [], text_nodes: []}}
  end

  def handle_event(:end_document, _data, state) do
    {:ok, state}
  end

  def handle_event(
        :start_element,
        {name, attributes},
        %{
          current_tag: _current_tag,
          text_elements: elements,
          text_nodes: nodes
        } = state
      ) do
    cond do
      not Enum.empty?(nodes) or not Enum.empty?(elements) ->
        handle_element(name, attributes, state)

      name == "text" ->
        handle_element(name, attributes, state)

      true ->
        {:ok, state}
    end
  end

  def handle_event(:end_element, _name, state) do
    {:ok, state}
  end

  def handle_event(:characters, chars, state) do
    cond do
      String.trim(chars) == "" ->
        {:ok, state}

      Enum.empty?(state[:text_nodes]) and Enum.empty?(state[:text_elements]) ->
        {:ok, state}

      true ->
        nodes = state[:text_nodes]
        el = %{tag_name: state[:current_tag], content: chars}
        {:ok, Map.put(state, :text_nodes, [el | nodes])}
    end
  end

  def handle_event(:cdata, _cdata, state) do
    {:ok, state}
  end

  defp handle_element(name, attributes, state) do
    els = state[:text_elements]
    {:ok, Map.put(state, :text_elements, [%{tag_name: name, attributes: attributes} | els])}
  end
end

# elements in <body>:
# div, p, milestone, term, add, l, lb, speaker, del, sp, quote
