defmodule Alixir.OSS.Callback do
  @enforce_keys [:url, :body]
  defstruct [
    :url,
    :body,
    body_type: "application/json"
  ]

  alias Alixir.OSS.Callback

  def encode(%Callback{url: url, body: body, body_type: "application/json"}) when is_map(body) do
    %{
      "callbackUrl": URI.encode(url),
      "callbackBody": Poison.encode!(body),
      "callbackBodyType": "application/json"
    }
    |> Poison.encode!()
    |> Base.encode64()
  end
end
