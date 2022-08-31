defmodule AWS.CodeGen.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aws_codegen,
      version: "0.0.1",
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  defp deps do
    [
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.23.0", only: :dev},
      {:floki, "~> 0.29"},
      {:fast_html, "~> 2.0"},
      {:poison, "~> 4.0 or ~> 5.0"}
    ]
  end
end
