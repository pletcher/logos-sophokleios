defmodule Xml.Docx.ChsFootnotesHandler do
  @behaviour Saxy.Handler

  def handle_event(_event_type, _data, user_state) do
    user_state
  end
end
