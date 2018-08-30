defmodule Alixir.OSS.PostObjectData do
  @default_expiration 60*5
  @policy_options_keys [:content_length_range, :expiration]

  alias Alixir.OSS.FileObject
  alias Alixir.OSS.Env
  alias Alixir.OSS.Utils

  def post_object_data(%FileObject{bucket: bucket, object_key: object_key}, policy_options \\ []) do
    content_type = Utils.content_type(object_key)
    policy =
      policy_options
      |> Keyword.take(@policy_options_keys)
      |> make_policy(bucket, object_key)
    signature = Alixir.Utils.sign(policy, Env.oss_access_key_id())

    %{
      "OSSAccessKeyId": Alixir.OSS.Env.oss_access_key_id(),
      "key": object_key,
      "Content-Type": content_type,
      "policy": policy,
      "Signature": signature
    }
  end

  defp make_policy(policy_options, bucket, object_key) do
    expiration_duration =
      policy_options
      |> Keyword.get(:expiration, @default_expiration)
      |> Timex.Duration.from_seconds()

    expiration =
      "GMT"
      |> Timex.now()
      |> Timex.add(expiration_duration)
      |> Utils.iso_8601_extended_time()

    %{
      "expiration": expiration,
      "conditions": make_policy_conditions(policy_options, bucket, object_key)
    }
    |> encode_policy()
  end

  defp make_policy_conditions(policy_options, bucket, object_key) do
    conditions =
      [
        %{"bucket": bucket},
        %{"key": object_key}
      ]

    case Keyword.get(policy_options, :content_length_range, nil) do
      {min, max} -> [["content-length-range", min, max] | conditions]
      nil -> conditions
    end
  end

  defp encode_policy(policy) do
    policy
    |> Poison.encode!()
    |> Base.encode64()
  end
end
