defmodule Tachometer.Mixfile do
  use Mix.Project

  def project do
    [app: :tachometer,
     version: "0.1.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     description: description,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger],
     mod: {Tachometer, []},
     registered: [Tachometer,
                  Tachometer.SchedulerPoller,
                  Tachometer.Supervisor]]
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
    []
  end

  defp description do
    """
    Scheduler instrumentation for BEAM in Elixir
    """
  end

  defp package do
    [# These are the default files included in the package
     maintainers: ["Paul Hieromnimon"],
     licenses: ["GNU GPLv3"],
     links: %{"GitHub" => "https://github.com/pavlos/tachometer",
              "Docs" => "https://github.com/pavlos/tachometer"}]
    end
end
