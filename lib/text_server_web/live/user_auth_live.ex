# adapted from Tate and DeBenedetto, 2022,
# _Programming Phoenix LiveView_, pp. 57--58

defmodule TextServerWeb.UserAuthLive do
  import Phoenix.LiveView

  alias TextServer.Accounts

  def on_mount(_, _params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    socket = socket |> assign(:current_user, user)

    # We continue no matter what here because we want
    # the LiveViews to be able to check if @current_user is nil
    {:cont, socket}
  end
end
