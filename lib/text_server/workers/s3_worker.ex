defmodule TextServer.Workers.S3Worker do
  use Oban.Worker

  alias ExAws.S3

  alias TextServer.Repo
  alias TextServer.TextElements
  alias TextServer.TextElements.TextElement

  import SweetXml

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
    text_element =
      TextElement
      |> TextElements.with_version()
      |> Repo.get!(id)

    save_to_s3(text_element)
  end

  def save_to_s3(text_element) do
    bucket_name = text_element.start_text_node.version.id
    urn = text_element.start_text_node.version.urn

    case S3.put_bucket(bucket_name, "us-east-1", [{:acl, :public_read}]) |> ExAws.request() do
      {:error, {:http_error, 409, _body}} ->
        # No need to worry about this error, it means we've already
        # created the bucket
        nil

      {:error, error} ->
        IO.inspect(error)

      {:ok, result} ->
        IO.inspect(result)
    end

    case S3.put_bucket_policy(bucket_name, bucket_policy(bucket_name)) |> ExAws.request() do
      {:ok, _} ->
        nil

      {:error, error} ->
        IO.inspect(error)
    end

    src = text_element.content
    dest = String.replace(src, "#{urn}/", "")

    {:ok, %{body: body}} =
      src
      |> S3.Upload.stream_file()
      |> S3.upload(bucket_name, dest)
      |> ExAws.request()

    new_src = xpath(body, ~x"//CompleteMultipartUploadResult/Location/text()") |> to_string()

    TextElements.update_text_element(text_element, %{content: new_src})
  end

  @doc """
  Returns a JSON string policy that, when applied, allows
  public read access to all of the objects in the bucket.
  It does not allow public write or listing of objects
  in the bucket --- those actions still require the
  access key etc.
  """
  def bucket_policy(bucket) do
    %{
      Version: "2012-10-17",
      Statement: [
        %{
          Sid: "Stmt1405592139000",
          Effect: "Allow",
          Principal: %{
            AWS: [
              "*"
            ]
          },
          Action: [
            "s3:GetObject"
          ],
          Resource: [
            "arn:aws:s3:::#{bucket}/*"
          ]
        }
      ]
    }
    |> Jason.encode!()
  end
end
