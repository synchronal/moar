defmodule Moar.MixProject do
  use Mix.Project

  def project do
    [
      app: :moar,
      deps: deps(),
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      version: "1.0.0"
    ]
  end

  def application do
    [extra_applications: extra_applications(Mix.env())]
  end

  # # #

  defp deps do
    [
      {:ex_doc, "~> 0.28.4", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp extra_applications(:test), do: [:crypto, :logger]
  defp extra_applications(_), do: [:logger]
end
