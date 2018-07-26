defmodule Alixir.OSS.Operation do
  defstruct [:http_method, :bucket, :object_key, :file, :oss_headers]

  alias Alixir.OSS.Utils
  alias Alixir.OSS.Env
  alias Alixir.OSS.Operation

  defimpl Alixir.Request.Operation do
    def perform(%Operation{http_method: http_method, bucket: bucket, object_key: object_key,
      file: file, oss_headers: oss_headers} = operation)
    do
      headers = Keyword.merge(oss_headers, build_common_headers(operation))

      %Alixir.Request{
        http_method: http_method,
        url: ~s(#{bucket}.#{Env.oss_endpoint}/#{object_key}),
        headers: headers,
        body: file
      }
    end

    defp build_common_headers(%Operation{http_method: http_method, bucket: bucket, object_key: object_key,
      oss_headers: oss_headers})
    do
      gmt_now = Utils.gmt_now()
      signature = Utils.make_signature(
        http_method |> to_string |> String.upcase,
        gmt_now,
        oss_headers,
        "/#{bucket}/#{object_key}"
      )

      [
        "Date": gmt_now,
        "Authorization": "OSS #{Env.oss_access_key_id}:#{signature}"
      ]
    end
  end
end
