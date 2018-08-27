defmodule Alixir.OSS.PresignedURL do
  @valid_http_methods [:get, :put, :delete]
  @default_expires 5 * 60

  alias Alixir.OSS.Env
  alias Alixir.OSS.Utils
  alias Alixir.OSS.FileObject
  alias Alixir.OSS.Callback

  def presigned_url(http_method, %FileObject{} = file_object, options \\ []) when http_method in @valid_http_methods do
    content_type =
      if :get == http_method do
        nil
      else
        Utils.content_type(file_object.object_key)
      end

    expires =
      options
      |> Keyword.get(:expires, @default_expires)
      |> Utils.expires_from(DateTime.utc_now)

    callback =
      options
      |> Keyword.get(:callback)
      |> make_callback()

    signature = Utils.make_signature(
      verb: http_method |> to_string() |> String.upcase(),
      content_md5: nil,
      content_type: content_type,
      date_or_expires: expires,
      oss_headers: [],
      resource: presigned_url_resource(file_object.bucket, file_object.object_key, callback)
    )

    %URI{
      scheme: "https",
      host: file_object.bucket <> "." <> Env.oss_endpoint(),
      path: "/" <> file_object.object_key,
      query: http_method |> presigned_url_parameters(content_type, signature, expires, callback) |> URI.encode_query()
    }
    |> URI.to_string()
  end

  defp make_callback(nil), do: nil
  defp make_callback(%Callback{} = callback), do: Callback.encode(callback)

  defp presigned_url_resource(bucket, object_key, callback \\ nil)
  defp presigned_url_resource(bucket, object_key, nil), do: Path.join(["/", bucket, object_key])
  defp presigned_url_resource(bucket, object_key, callback) do
    %URI{
      path: presigned_url_resource(bucket, object_key),
      query: %{callback: callback} |> Enum.map_join("&", fn {key, value} -> "#{key}=#{value}" end)
    }
    |> URI.to_string()
  end

  defp presigned_url_parameters(:get, _content_type, signature, expires, _callback) do
    %{
      "Signature": signature,
      "Expires": expires,
      "OSSAccessKeyId": Env.oss_access_key_id()
    }
  end
  defp presigned_url_parameters(:put, content_type, signature, expires, nil) do
    %{
      "Content-Type": content_type,
      "Signature": signature,
      "Expires": expires,
      "OSSAccessKeyId": Env.oss_access_key_id()
    }
  end
  defp presigned_url_parameters(:put, content_type, signature, expires, callback) do
    %{
      "Content-Type": content_type,
      "Signature": signature,
      "Expires": expires,
      "callback": callback,
      "OSSAccessKeyId": Env.oss_access_key_id()
    }
  end
end
