defmodule Alixir.OSS.Operation do
  defstruct [:http_method, :bucket, :object_key, :file, :oss_headers]

  alias Alixir.OSS.Utils
  alias Alixir.OSS.Env
  alias Alixir.OSS.Operation

  defimpl Alixir.Request.Operation do
    @doc """
    ## Examples

      iex> operation = %Alixir.OSS.Operation{http_method: :put, bucket: "foo", object_key: "foo/bar.jpg",
      ...>   file: "filecontent", oss_headers: ["X-OSS-Object-Acl": "public-read"]}
      ...> request = Alixir.Request.Operation.perform(operation)
      ...> with %Alixir.Request{http_method: :put, url: _, headers: headers, body: "filecontent"} <- request
      ...> do
      ...>   if(Keyword.has_key?(headers, :"Date") && Keyword.has_key?(headers, :"Content-Type") &&
      ...>     Keyword.has_key?(headers, :"Authorization"), do: true, else: false)
      ...> end
      true
    """
    def perform(%Operation{http_method: http_method, bucket: bucket, object_key: object_key,
      file: file, oss_headers: oss_headers} = operation)
    do
      headers = Keyword.merge(oss_headers, build_common_headers(operation))

      %Alixir.Request{
        http_method: http_method,
        url: ~s(#{bucket}.#{Env.oss_endpoint}/#{object_key}),
        headers: headers,
        body: file || ""
      }
    end

    defp build_common_headers(%Operation{http_method: http_method, bucket: bucket, object_key: object_key,
      oss_headers: oss_headers})
    do
      content_type = Utils.content_type(object_key)
      gmt_now = Utils.gmt_now()
      signature = Utils.make_signature(
        verb: http_method |> to_string |> String.upcase,
        content_md5: nil,
        content_type: content_type,
        date_or_expires: gmt_now,
        oss_headers: oss_headers,
        resource: "/#{bucket}/#{object_key}"
      )

      [
        "Date": gmt_now,
        "Content-Type": content_type,
        "Authorization": "OSS #{Env.oss_access_key_id}:#{signature}"
      ]
    end
  end
end
