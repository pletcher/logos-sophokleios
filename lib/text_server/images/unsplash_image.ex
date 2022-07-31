defmodule TextServer.Images.UnsplashImage do
  defstruct [
    :attribution_name,
    :attribution_url,
    :blur_hash,
    :description,
    :download_link,
    :image_url,
    attribution_source: "Unsplash",
    attribution_source_url: "https://unsplash.com/?utm_source=Open%20Commentaries&utm_medium=referral"
  ]
end
