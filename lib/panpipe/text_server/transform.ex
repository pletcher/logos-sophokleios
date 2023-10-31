defmodule Panpipe.TextServer.Transform do
  @location_regex ~r/\{\d+\.\d+\.\d+\}/

  @moduledoc """
  Essentially, this is the problem that we're encountering:
  https://github.com/pandoc/lua-filters/issues/251. Instead
  of using the AST to output (e.g.) Markdown or TEI,
  we need to walk it and output text in TextNodes format.

  TextNodes themselves could just be markdown, but they need
  additional information -- location attributes, specifically
  -- that can't be attached to all Pandoc nodes.
  """
  def transform_ast(%Panpipe.Document{} = ast) do
    ast |> Panpipe.transform(&mark_location/1)
  end

  def mark_location(%Panpipe.AST.Para{children: children}) do
    [h | _rest] = children

    case h do
      %Panpipe.AST.Str{string: string} ->
        matches = Regex.run(@location_regex, string)

        if !is_nil(matches) && length(matches) > 0 do
          location =
            List.first(matches)
            |> String.replace("{", "")
            |> String.replace("}", "")

          Process.put(:current_document_location, location)

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
        nil
    end
  end

  def mark_location(n) do
    if Panpipe.AST.Node.block?(n) do
      div = %Panpipe.AST.Div{children: n.children}
      location = Process.get(:current_document_location)

      %{
        div
        | attr: %Panpipe.AST.Attr{
            identifier: location,
            key_value_pairs: %{"location" => location}
          }
      }
    end
  end
end
