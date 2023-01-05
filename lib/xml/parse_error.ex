defmodule Xml.ParseError do
  defexception [:message]

  @impl true
  def exception(value) do
    msg = "Error parsing XML: #{inspect(value)}"

    %Xml.ParseError{message: msg}
  end
end
