defmodule TextServer.Images.UnsplashApi do
  use Tesla

  alias TextServer.Images.UnsplashImage

  plug Tesla.Middleware.BaseUrl, "https://api.unsplash.com/search/photos"

  plug Tesla.Middleware.Headers, [
    {"Accept-Version", "v1"},
    {"Authorization", "Client-ID #{Application.get_env(:text_server, :unsplash_access_key)}"}
  ]

  plug Tesla.Middleware.JSON

  def search(query, opts \\ []) do
    qs = query_string(opts ++ [query: query])

    case get("/search/photos?#{qs}") do
      {:ok, response} -> handle_search_results(response.body)
      _ -> IO.puts("Something went wrong with that request.")
    end
  end

  def handle_search_results(json) do
    %{
      "total" => total,
      "total_pages" => total_pages,
      "results" => results
    } = json

    images = results |> Enum.map(&format_result/1)

    %{
      images: images,
      total: total,
      total_pages: total_pages
    }
  end

  defp format_result(image_data) do
    %{
      "blur_hash" => blur_hash,
      "description" => description,
      "user" => user,
      "links" => links,
      "urls" => urls
    } = image_data

    attribution_name = Map.get(user, "name")
    attribution_url = Map.get(links, "html")
    download_link = Map.get(links, "download_location")
    image_url = Map.get(urls, "small")

    %UnsplashImage{
      attribution_name: attribution_name,
      attribution_url: "#{attribution_url}?utm_source=Open%20Commentaries&utm_medium=referral",
      blur_hash: blur_hash,
      description: description,
      download_link: download_link,
      image_url: image_url
    }
  end

  defp query_string(opts) do
    opts |> Enum.map_join("&", fn {k, v} -> "#{k}=#{v}" end)
  end
end
