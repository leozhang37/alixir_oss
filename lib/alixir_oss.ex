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

  alias Alixir.OSS.Operation

  @doc """
  Put object to OSS. Return an `Alixir.OSS.Operation` struct which
  could be passed to `Alixir.request` to perform the
  request.

  ## Example

    iex> operation = Alixir.OSS.put_object("foo_bucket", "foo/bar.jpg", File.stream!("test/data/bar.jpg"), "X-OSS-Object-Acl": "public-read")
    ...> with %Alixir.OSS.Operation{http_method: :put, bucket: "foo_bucket", object_key: "foo/bar.jpg",
    ...>   file: %File.Stream{path: "test/data/bar.jpg"}, oss_headers: oss_headers} when is_list(oss_headers) <- operation, do: true
    true
  """
  @spec put_object(
    String.t(),
    String.t(),
    Enumerable.t(),
    list()
  ) :: %Alixir.OSS.Operation{http_method: :put}
  def put_object(bucket, object_key, file, oss_headers \\ []) when is_list(oss_headers) do
    %Operation{
      http_method: :put,
      bucket: bucket,
      object_key: object_key,
      file: file,
      oss_headers: oss_headers
    }
  end

  @doc """
  Delete object from OSS. Return an `Alixir.OSS.Operation` struct which
  could be passed to `Alixir.request` to perform the
  request.

  ## Example

    iex> operation = Alixir.OSS.delete_object("foo_bucket", "foo/bar.jpg")
    ...> with %Alixir.OSS.Operation{http_method: :delete, bucket: "foo_bucket", object_key: "foo/bar.jpg",
    ...>   oss_headers: oss_headers} when is_list(oss_headers) <- operation, do: true
    true
  """
  @spec delete_object(
    String.t(),
    Enumerable.t(),
    list()
  ) :: %Alixir.OSS.Operation{http_method: :delete}
  def delete_object(bucket, object_key, oss_headers \\ []) when is_list(oss_headers) do
    %Operation{
      http_method: :delete,
      bucket: bucket,
      object_key: object_key,
      oss_headers: oss_headers
    }
  end
end
