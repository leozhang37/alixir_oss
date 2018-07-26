defmodule Alixir.Request do
  defstruct [
    :http_method,
    :url,
    :params,
    :headers,
    :body
  ]

  alias Alixir.Request

  @type status_code :: integer
  @type body :: String.t
  @type reason :: String.t

  @spec perform(%Request{}) :: {:ok, status_code, body} | {:error, status_code, reason}
  def perform(%Request{http_method: http_method, url: url, params: params, headers: headers, body: body})
    when http_method in ~w{put delete}
  do
    with {:ok, %HTTPoison.Response{body: body, status_code: code}} <- HTTPoison.request(http_method, url, body, headers, params: params)
    do
      {:ok, code, body}
    else
      {:error, reason} -> {:error, nil, reason}
    end
  end
end
