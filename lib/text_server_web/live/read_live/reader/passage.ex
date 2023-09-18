defmodule TextServerWeb.ReadLive.Reader.Passage do
  use TextServerWeb, :live_component

  attr :passage, :string, required: true

  def render(assigns) do
    ~H"""
    <div id="reader-passage" phx-hook="TEIHook">
      <%= raw @passage %>
    </div>
    """
  end
end
