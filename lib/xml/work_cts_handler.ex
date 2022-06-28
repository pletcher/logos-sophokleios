defmodule Xml.WorkCtsHandler do
  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _data, {_current_element, works}) do
    {:ok, works}
  end

  def handle_event(:start_element, {name, attributes}, state),
    do: handle_element(name, attributes, state)

  def handle_event(:end_element, name, {_current_element, works}) do
    {:ok, {nil, works}}
  end

  def handle_event(:characters, chars, {current_element, works}) do
    if String.trim(chars) == "" do
      {:ok, {nil, works}}
    else
      [work | works] = works
      {:ok, {nil, [Map.put(work, current_element, chars) | works]}}
    end
  end

  def handle_event(:characters, _chars, {current_element, works}) do
    IO.inspect("Not sure what to do with the characters for unknown element #{current_element}")
    {:ok, {nil, works}}
  end

  def handle_event(:cdata, cdata, state) do
    IO.inspect("Receive CData #{cdata}")
    {:ok, state}
  end

  defp handle_element("ti:about", attributes, state), do: handle_about(attributes, state)

  defp handle_element("ti:commentary", attributes, state),
    do: handle_commentary(attributes, state)

  defp handle_element("cts:description", attributes, state),
    do: handle_description(attributes, state)

  defp handle_element("ti:description", attributes, state),
    do: handle_description(attributes, state)

  defp handle_element("description", attributes, state),
    do: handle_description(attributes, state)

  defp handle_element("cts:edition", attributes, state), do: handle_edition(attributes, state)
  defp handle_element("ti:edition", attributes, state), do: handle_edition(attributes, state)
  defp handle_element("edition", attributes, state), do: handle_edition(attributes, state)

  defp handle_element("cts:label", attributes, state), do: handle_label(attributes, state)
  defp handle_element("ti:label", attributes, state), do: handle_label(attributes, state)
  defp handle_element("label", attributes, state), do: handle_label(attributes, state)

  defp handle_element("cts:title", attributes, state), do: handle_title(attributes, state)
  defp handle_element("ti:title", attributes, state), do: handle_title(attributes, state)
  defp handle_element("title", attributes, state), do: handle_title(attributes, state)

  defp handle_element("cts:translation", attributes, state),
    do: handle_translation(attributes, state)

  defp handle_element("ti:translation", attributes, state),
    do: handle_translation(attributes, state)

  defp handle_element("translation", attributes, state), do: handle_translation(attributes, state)

  defp handle_element("cts:work", attributes, state), do: handle_work(attributes, state)
  defp handle_element("ti:work", attributes, state), do: handle_work(attributes, state)
  defp handle_element("work", attributes, state), do: handle_work(attributes, state)

  # TODO: It's currently unclear what we should do about these elements. We can
  # resolve this TODO when we have explicit actions (or non-actions) for each of
  # them
  defp handle_element("cpt:structured-metadata", attributes, state), do: {:ok, state}
  defp handle_element("dct:hasVersion", attributes, state), do: {:ok, state}
  defp handle_element("dct:isVersionOf", attributes, state), do: {:ok, state}
  defp handle_element("foreign", attributes, state), do: {:ok, state}
  defp handle_element("ti:memberof", attributes, state), do: {:ok, state}
  defp handle_element("memberof", attributes, state), do: {:ok, state}
  # END unhandled elements

  defp handle_element(name, _attributes, state) do
    IO.inspect("Received unknown element #{name}")
    {:halt, state}
  end

  defp handle_about(attributes, {current_element, works}) do
    [w | works] = works
    attrs = Map.new(attributes)
    work = Map.replace(w, :about_urns, [attrs[:urn] | Map.get(w, :about_urns, [])])

    {:ok, {current_element, [work | works]}}
  end

  defp handle_commentary(attributes, {_current_element, works}) do
    attrs = Map.new(attributes)
    commentary = %{urn: attrs["urn"], work_urn: attrs["workUrn"]}

    {:ok, {:commentary, [commentary | works]}}
  end

  defp handle_description(_attributes, {_current_element, works}) do
    {:ok, {:description, works}}
  end

  defp handle_edition(attributes, {_current_element, works}) do
    attrs = Map.new(attributes)
    edition = %{version_type: :edition, work_urn: attrs["workUrn"], urn: attrs["urn"]}

    {:ok, {:edition, [edition | works]}}
  end

  defp handle_label(_attributes, {_current_element, works}) do
    {:ok, {:label, works}}
  end

  defp handle_title(_attributes, {_current_element, works}) do
    {:ok, {:title, works}}
  end

  defp handle_translation(attributes, {_current_element, works}) do
    attrs = Map.new(attributes)

    translation = %{
      version_type: :translation,
      work_urn: attrs["workUrn"],
      urn: attrs["urn"]
    }

    {:ok, {:translation, [translation | works]}}
  end

  defp handle_work(attributes, {_current_element, works}) do
    attrs = Map.new(attributes)
    work = %{text_group_urn: attrs["groupUrn"], urn: attrs["urn"]}

    {:ok, {:work, [work | works]}}
  end
end
