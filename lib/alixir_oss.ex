defmodule Alixir.OSS do
  @moduledoc """
  `Alixir.OSS` enables puting and deleting objects for Aliyun
  OSS.

  ## Examples

    ```
    Alixir.OSS.put_object(args...)
    |> Alixir.request()

    Alixir.OSS.delete_objects(args...)
    |> Alixir.request()
    ```

  See `put_object/4` and `delete_object/4` for more details.
  """

  @valid_http_methods [:get, :put, :delete]
  @default_expires 5 * 60

  alias Alixir.OSS.FileObject
  alias Alixir.OSS.Operation
  alias Alixir.OSS.Utils
  alias Alixir.OSS.Env

  @doc """
  Put object to OSS. Return an `Alixir.OSS.Operation` struct which
  could be passed to `Alixir.request` to perform the
  request.

  ## Example

    iex> file_object = %Alixir.OSS.FileObject{bucket: "foo_bucket", object_key: "foo/bar.jpg", object: File.stream!("test/data/bar.jpg")}
    ...> operation = Alixir.OSS.put_object(file_object, "X-OSS-Object-Acl": "public-read")
    ...> with %Alixir.OSS.Operation{http_method: :put, bucket: "foo_bucket", object_key: "foo/bar.jpg",
    ...>   file: %File.Stream{path: "test/data/bar.jpg"}, oss_headers: oss_headers} when is_list(oss_headers) <- operation, do: true
    true
  """
  @spec put_object(
    %FileObject{},
    list()
  ) :: %Alixir.OSS.Operation{http_method: :put}
  def put_object(%FileObject{bucket: bucket, object_key: object_key, object: object}, oss_headers \\ []) when is_list(oss_headers) do
    %Operation{
      http_method: :put,
      bucket: bucket,
      object_key: object_key,
      file: object,
      oss_headers: oss_headers
    }
  end

  @doc """
  Delete object from OSS. Return an `Alixir.OSS.Operation` struct which
  could be passed to `Alixir.request` to perform the
  request.

  ## Example

    iex> file_object = %Alixir.OSS.FileObject{bucket: "foo_bucket", object_key: "foo/bar.jpg"}
    ...> operation = Alixir.OSS.delete_object(file_object)
    ...> with %Alixir.OSS.Operation{http_method: :delete, bucket: "foo_bucket", object_key: "foo/bar.jpg",
    ...>   oss_headers: oss_headers} when is_list(oss_headers) <- operation, do: true
    true
  """
  @spec delete_object(
    %FileObject{},
    list()
  ) :: %Alixir.OSS.Operation{http_method: :delete}
  def delete_object(%FileObject{bucket: bucket, object_key: object_key}, oss_headers \\ []) when is_list(oss_headers) do
    %Operation{
      http_method: :delete,
      bucket: bucket,
      object_key: object_key,
      oss_headers: oss_headers
    }
  end

  @doc """
  Generate a presigned URL, which could be used by other other applications (such as
  frontend) to operate OSS
  """
  @spec presigned_url(
    atom(),
    %FileObject{},
    Keyword.t()
  ) :: String.t()
  def presigned_url(http_method, %FileObject{} = file_object, options \\ []) when http_method in @valid_http_methods do
    content_type = Utils.content_type(file_object.object_key)
    expires =
      options
      |> Keyword.get(:expires, @default_expires)
      |> Utils.expires_from(DateTime.utc_now)

    signature = Utils.make_signature(
      verb: http_method |> to_string() |> String.upcase(),
      content_md5: nil,
      content_type: content_type,
      date_or_expires: expires,
      oss_headers: [],
      resource: Path.join(file_object.bucket, file_object.object_key)
    )

    parameters =
      %{
        "Content-Type": content_type,
        "Signature": signature,
        "Expires": expires,
        "OSSAccessKeyId": Env.oss_access_key_id()
      }

    %URI{
      scheme: "https",
      host: file_object.bucket <> "." <> Env.oss_endpoint(),
      path: "/" <> file_object.object_key,
      query: URI.encode_query(parameters)
    }
    |> URI.to_string()
  end
end
