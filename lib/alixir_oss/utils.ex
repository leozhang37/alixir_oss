defmodule Alixir.OSS.Utils do
  @default_content_type "application/octet-stream"

  def make_signature(verb: verb, content_md5: content_md5, content_type: content_type,
    date_or_expires: date_or_expires, oss_headers: oss_headers, resource: resource)
  do
    parameters =
      if Enum.empty?(oss_headers) do
        [verb, content_md5, content_type, date_or_expires, resource]
      else
        [verb, content_md5, content_type, date_or_expires,
          canonicalized_oss_headers_string(oss_headers), resource]
      end

    parameters |> Enum.join("\n") |> sign_with(Alixir.OSS.Env.oss_access_key_secret)
  end

  def sign_with(string, key) do
    :crypto.hmac(:sha, key, string) |> Base.encode64
  end

  def gmt_now do
    Timex.format!(Timex.now, "%a, %d %b %Y %H:%M:%S GMT", :strftime)
  end

  def content_type(object_key) do
    case Path.extname(object_key) do
      "." <> ext -> MIME.type(ext)
      _ -> @default_content_type
    end
  end

  defp canonicalized_oss_headers_string(oss_headers) do
    oss_headers
    |> Enum.map(fn {key, value} -> "#{key |> to_string |> String.downcase}:#{value}" end)
    |> Enum.sort
    |> Enum.join("\n")
  end
end
