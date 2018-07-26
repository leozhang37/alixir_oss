defmodule Alixir.OSS.Utils do
  def make_signature(verb, content_md5 \\ "", content_type \\ "", date_or_expires, oss_headers, resource) do
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
    :crypto.hmac(:sha, key, string)
  end

  def gmt_now do
    Timex.format!(Timex.now, "%a, %d %b %Y %H:%M:%S GMT", :strftime)
  end

  defp canonicalized_oss_headers_string(oss_headers) do
    oss_headers
    |> Enum.map(fn {key, value} -> "#{String.downcase(key)}:#{value}" end)
    |> Enum.sort
    |> Enum.join("\n")
  end
end
