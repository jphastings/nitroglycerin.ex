defmodule Nitro.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nitro,
      version: "0.1.0",
      elixir: "~> 1.3",
      description: "A library for managing one-time pad encryption",
      package: package,
      deps: deps,
      docs: [extras: ["README.md"]],
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package do
    [
      name: :nitro,
      files: ["lib", "mix.exs"],
      maintainers: ["JP Hastings-Spital"],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/jphastings/nitro.ex"
      },
    ]
  end
end