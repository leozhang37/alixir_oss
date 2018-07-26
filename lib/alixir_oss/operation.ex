defmodule Alixir.OSS.Operation do
  defstruct [:http_method, :bucket, :object_key, :file, :headers]

  defimpl Alixir.Request.Operation do
    def perform(%Alixir.OSS.Operation{http_method: http_method, bucket: bucket, object_key: object_key, file: file, headers: headers}) do
      %Alixir.Request{
        http_method: http_method,
        url: ~s(#{bucket}.#{Alixir.OSS.Env.oss_endpoint}/#{object_key}),
        headers: headers,
        body: file
      }
    end
  end
end
