defmodule Alixir.OSS.Env do
  def oss_endpoint do
    Application.get_env(:alixir_oss, :oss_endpoint, "")
  end

  def oss_access_key_id do
    Application.get_env(:alixir_oss, :oss_access_key_id, "")
  end

  def oss_access_key_secret do
    Application.get_env(:alixir_oss, :oss_access_key_secret, "")
  end
end
