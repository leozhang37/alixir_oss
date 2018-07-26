defmodule Alixir.Request do
  defstruct [
    :http_method,
    :url,
    :params,
    :headers,
    :body
  ]
end
