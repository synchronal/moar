defmodule Moar.MixProject do
  use Mix.Project

  def project do
    [
      app: :moar,
      deps: deps(),
      dialyzer: dialyzer(),
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
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.28.4", only: :dev, runtime: false},
      {:mix_audit, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp dialyzer, do: [plt_add_apps: [:ex_unit]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp extra_applications(:test), do: [:crypto, :logger]
  defp extra_applications(_), do: [:logger]
end
