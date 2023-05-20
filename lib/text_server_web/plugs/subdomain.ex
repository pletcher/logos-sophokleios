defmodule TextServerWeb.Plugs.Subdomain do
  @behaviour Plug

  import Plug.Conn, only: [put_private: 3, halt: 1]

  def init(opts) do
    root_host = Application.get_env(:text_server, TextServerWeb.Endpoint)[:url][:host]

    Map.merge(
      opts,
      %{root_host: root_host}
    )
  end

  def call(
        %Plug.Conn{host: host} = conn,
        %{root_host: root_host, subdomain_router: router} = _opts
      ) do
    case extract_subdomain(host, root_host) do
      subdomain when byte_size(subdomain) > 0 ->
        put_private(conn, :subdomain, subdomain)
        |> router.call(router.init({}))
        |> halt()

      _ ->
        conn
    end
  end

  defp extract_subdomain(host, root_host) do
    host =
      case host do
        "www.example.com" -> "localhost"
        _ -> host
      end

    String.replace(host, ~r/.?#{root_host}/, "")
  end
end
