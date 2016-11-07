defmodule Nitroglycerin.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nitroglycerin,
      version: "0.1.1",
      elixir: "~> 1.3",
      description: "A library for managing one-time pad encryption",
      package: package,
      deps: deps,
      docs: [extras: ["README.md"]],
      preferred_cli_env: [espec: :test],
      escript: [main_module: Nitroglycerin.Executable],
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev},
      {:espec, "~> 1.1", only: :test},
    ]
  end

  defp package do
    [
      name: :nitroglycerin,
      files: ["lib", "mix.exs"],
      maintainers: ["JP Hastings-Spital"],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/jphastings/nitroglycerin.ex"
      },
    ]
  end
end
