defmodule Alixir.OSS.Utils do
  @default_content_type "application/octet-stream"

  defdelegate gmt_now(), to: Alixir.Utils

  def make_signature(
    verb: verb, content_md5: content_md5, content_type: content_type,
    date_or_expires: date_or_expires, oss_headers: oss_headers, resource: resource
  ) do
    parameters =
      if Enum.empty?(oss_headers) do
        [verb, content_md5, content_type, date_or_expires, resource]
      else
        [
          verb, content_md5, content_type, date_or_expires,
          canonicalize_parameters(oss_headers), resource
        ]
      end

    parameters |> Enum.join("\n") |> Alixir.Utils.sign(Alixir.OSS.Env.oss_access_key_secret)
  end

  def content_type(object_key) do
    case Path.extname(object_key) do
      "." <> ext -> MIME.type(ext)
      _ -> @default_content_type
    end
  end

  def expires_from(expires, %DateTime{} = time) do
    expires + (time |> DateTime.to_unix)
  end

  defp canonicalize_parameters(parameters) do
    parameters
    |> Enum.map(fn {key, value} -> "#{key |> to_string() |> String.downcase()}:#{value}" end)
    |> Enum.sort()
    |> Enum.join("\n")
  end
end
