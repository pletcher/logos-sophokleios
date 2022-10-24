defmodule Xml.Docx.ChsPeopleHandler do
  @behaviour Saxy.Handler

  def handle_event(_event_type, _data, user_state) do
    user_state
  end
end
