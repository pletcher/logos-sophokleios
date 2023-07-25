defmodule Exist.HttpApi do
  use Tesla

  # NOTE: (charles) For now, the base URL should include the "cts"
  # scheme identifier.
  plug Tesla.Middleware.BaseUrl, Application.get_env(:text_server, :exist_db_url)

  plug Tesla.Middleware.Headers, [
    {"authorization",
     "Basic" <>
       :base64.encode(
         Application.get_env(:text_server, :exist_db_username, "admin") <>
           ":" <> Application.get_env(:text_server, :exist_db_password, "")
       )}
  ]

  @doc """
  Gets the XML document based on the supplied URN. If the URN
  does not resolve to a specific version, we will try to get
  the __cts__.xml file at the specified depth. Otherwise, the
  request will fail.

  Example:

  > get_document("urn:cts:greekLit:tlg0012.tlg001.perseus-grc2")
  > # Perseus XML for the grc2 version of Homer, _Iliad_.
  """
  def get_document(urn) do
    case String.split(urn, ":") do
      ["urn", "cts", collection, rest] ->
        get_text_group(collection, rest)

      ["urn", "cts", collection, rest, passage] ->
        get_passage(collection, rest, passage)

      _ ->
        {:error, "Invalid URN"}
    end
  end

  def get_text_group(collection, rest) do
    case String.split(rest, ".") do
      [text_group, work, version] ->
        get_version(collection, text_group, work, version)

      [text_group, work] ->
        get_work(collection, text_group, work)

      [text_group] ->
        get("#{collection}/#{text_group}/__cts__.xml")
    end
  end

  def get_work(collection, text_group, work) do
    get("#{collection}/#{text_group}/#{work}/__cts__.xml")
  end

  def get_version(collection, text_group, work, version) do
    get("#{collection}/#{text_group}/#{work}/#{text_group}.#{work}.#{version}.xml")
  end

  def get_passage(collection, rest, _passage) do
    [text_group, work, version] = String.split(rest, ".")

    get("#{collection}/#{text_group}/#{work}/#{text_group}.#{work}.#{version}.xml/?_query=")
  end
end
