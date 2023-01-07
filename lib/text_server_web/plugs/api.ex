defmodule TextServerWeb.Plugs.API do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller

  @one_year 365 * 24 * 60 * 60

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> get_token()
    |> verify_token()
    |> case do
      {:ok, user_id} ->
        IO.inspect(user_id)
        assign(conn, :current_user, user_id)
      _unauthorized -> assign(conn, :current_user, nil)
    end
  end

  def authenticate_api_user(conn, _opts) do
    if Map.get(conn.assigns, :current_user) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(TextServerWeb.ErrorView)
      |> render(:"401")
      |> halt()
    end
  end

  def generate_token(user_id) do
    Phoenix.Token.sign(
      TextServerWeb.Endpoint,
      TextServerWeb.Endpoint.config(:secret_key_base),
      user_id
    )
  end

  @spec verify_token(nil | binary) :: {:error, :expired | :invalid | :missing} | {:ok, any}
  def verify_token(token) do
    Phoenix.Token.verify(
      TextServerWeb.Endpoint,
      TextServerWeb.Endpoint.config(:secret_key_base),
      token,
      max_age: @one_year
    )
  end

  @spec get_token(Plug.Conn.t()) :: nil | binary
  defp get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end
end
