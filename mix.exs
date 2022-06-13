defmodule Moar.MixProject do
  use Mix.Project

  @scm_url "https://github.com/synchronal/moar"
  @version "1.13.1"

  def project do
    [
      app: :moar,
      deps: deps(),
      description: "An assortment of useful functions.",
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      homepage_url: @scm_url,
      name: "Moar",
      package: package(),
      preferred_cli_env: [credo: :test, dialyzer: :test],
      source_url: @scm_url,
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  def application do
    [extra_applications: extra_applications(Mix.env())]
  end

  # # #

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.28.4", only: :dev, runtime: false},
      {:mix_audit, "~> 1.0", only: :dev, runtime: false},
      {:mix_test_interactive, "~> 1.2", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit],
      plt_add_deps: :app_tree,
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE.md"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp extra_applications(:test), do: [:crypto, :logger]
  defp extra_applications(_), do: [:logger]

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["synchronal.dev", "Erik Hanson", "Eric Saxby"],
      links: %{"GitHub" => @scm_url}
    ]
  end
end
