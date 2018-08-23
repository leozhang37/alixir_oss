defmodule Alixir.OSS.FileObject do
  @enforce_keys [:bucket, :object_key]
  defstruct [
    :bucket,
    :object_key,
    :object
  ]
end
