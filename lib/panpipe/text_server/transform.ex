defmodule Panpipe.TextServer.Transform do
  @location_regex ~r/\{\d+\.\d+\.\d+\}/

  def transform_ast(%Panpipe.Document{} = ast) do
    ast |> Panpipe.transform(&transform_node/1)
  end

  def transform_node(%Panpipe.AST.Para{} = node) do
    [h | rest] = Map.get(node, :children)

    case h do
      %Panpipe.AST.Str{string: string} ->
        matches = Regex.run(@location_regex, string)

        if !is_nil(matches) && length(matches) > 0 do
          location =
            List.first(matches)
            |> String.replace("{", "")
            |> String.replace("}", "")
            |> String.split(".")

          # The text node now begins with an empty space,
          # so we remove it
          [children | _rest] = rest

          div = %Panpipe.AST.Div{children: children}

          %{
            div
            | attr: %Panpipe.AST.Attr{
                identifier: location,
                key_value_pairs: %{"location" => location}
              }
          }
        end

      _ ->
        node
    end
  end

  def transform_node(node), do: node
end
