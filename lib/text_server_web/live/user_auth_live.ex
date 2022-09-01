# adapted from Tate and DeBenedetto, 2022,
# _Programming Phoenix LiveView_, pp. 57--58

defmodule TextServerWeb.UserAuthLive do
  import Phoenix.LiveView

  alias TextServer.Accounts
  alias TextServerWeb.Router.Helpers, as: Routes

  def on_mount(_, _params, %{"user_token" => user_token}, socket) do
	  socket = assign_new(socket, :current_user, fn ->
	    Accounts.get_user_by_session_token(user_token)
	  end)

	  if socket.assigns.current_user do
	    {:cont, socket}
	  else
	    {:halt, redirect(socket, to: Routes.user_session_path(socket, :new))}
	  end
  end
end
