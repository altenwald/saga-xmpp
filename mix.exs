defmodule Saga.Mixfile do
  use Mix.Project

  def project do
    [app: :saga,
     version: "0.1.0",
     elixir: "~> 1.7",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     aliases: aliases(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test,
                         "coveralls.detail": :test,
                         "coveralls.post": :test,
                         "coveralls.html": :test,
                         "coveralls.json": :test]]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Saga, []}]
  end

  defp deps do
    [{:ranch, "~> 1.4.0"},
     {:hashids, "~> 2.0"},
     {:timex, "~> 3.1.24"},
     {:gen_state_machine, "~> 2.0.1"},

     {:logger_file_backend, "~> 0.0.7"},
     {:syslog, github: "altenwald/syslog"},

     # delivery database backend:
     {:dbi, "~> 1.1.3"},
     {:dbi_pgsql, "~> 0.2.0"},

     # workers pool
     {:poolboy, "~> 1.5.0"},

     # test deps:
     {:credo, "~> 0.8.10", only: :dev},
     {:excoveralls, "~> 0.7.3", only: :test}]
  end

  defp aliases do
    [
      bootstrap: ["local.rebar --force",
                  "local.hex --force"],
      "compile.full": ["deps.get", "compile"],
      test: ["test --cover", "coveralls.json"]
    ]
  end
end
