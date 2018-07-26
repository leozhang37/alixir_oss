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
  alias Alixir.OSS.Utils

  @doc """
  Put object to OSS. Return an `AlixirOSS.Operation` struct which
  could be passed to `AlixirOSS.Request.request` to perform the
  request.

  ## Example

    iex> operation = Alixir.OSS.put_object("foo_bucket", "foo/bar.jpg", File.stream!("test/data/bar.jpg"), "X-OSS-Object-Acl": "public-read")
    ...> with %Alixir.OSS.Operation{http_method: :put, bucket: "foo_bucket", object_key: "foo/bar.jpg",
    ...>   file: %File.Stream{path: "test/data/bar.jpg"}, headers: headers} when is_list(headers) <- operation, do: true
    true
  """
  @spec put_object(
    String.t(),
    String.t(),
    Enumerable.t(),
    Enumerable.t()
  ) :: tuple()
  def put_object(bucket, object_key, file, oss_headers \\ []) when is_list(oss_headers) do
    gmt_now = Utils.gmt_now()
    signature = Utils.make_signature(
      "PUT",
      gmt_now,
      [],
      "/#{bucket}/#{object_key}"
    )

    headers = [
      "Authorization": "OSS #{Alixir.OSS.Env.oss_access_key_id}:#{signature}",
      "Date": gmt_now
    ]

    %Operation{
      http_method: :put,
      bucket: bucket,
      object_key: object_key,
      file: file,
      headers: Keyword.merge(oss_headers, headers)
    }
  end

  def delete_object do
  end
end
