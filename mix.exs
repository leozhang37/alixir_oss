defmodule AlixirOss.MixProject do
  use Mix.Project

  def project do
    [
      app: :alixir_oss,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:timex]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.2.0"},
      {:timex, "~> 3.3"}
    ]
  end
end
