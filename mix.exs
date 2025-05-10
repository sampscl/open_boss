defmodule OpenBoss.MixProject do
  use Mix.Project

  @app :open_boss
  @all_targets [
    :rpi4,
    :rpi4_kiosk,
    :x86_64
  ]

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env(), Mix.target()),
      archives: [nerves_bootstrap: "~> 1.13"],
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host],
      dialyzer: [plt_add_apps: [:mix], ignore_warnings: "dialyzer_ignore_warnings.exs"]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {OpenBoss.Application, []},
      extra_applications: [:logger, :inets, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(env, target) do
    env =
      case env do
        :test -> ["test/support"]
        _ -> []
      end

    target =
      case target do
        host when host in [:host, :""] -> ["platform/host"]
        :rpi4_kiosk -> ["platform/target", "platform/rpi4_kiosk"]
        _target -> ["platform/target"]
      end

    ["lib"] ++ env ++ target
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      #
      # Phoenix and project deps
      #
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.7", only: [:test]},
      {:phoenix, "~> 1.7"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:ecto_sqlite3_extras, "~> 1.2.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0", override: true},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:bandit, "~> 1.5"},
      {:uuid, "~> 1.0"},
      {:mdns, "~> 1.0"},
      {:tzdata, "~> 1.1"},
      {:emqtt, github: "emqx/emqtt", tag: "1.13.5", system_env: [{"BUILD_WITHOUT_QUIC", "1"}]},
      {:timex, "~> 3.7"},
      {:x509, "~> 0.8"},

      #
      # Nerves deps
      #

      # Dependencies for all targets
      {:nerves, "~> 1.7.16 or ~> 1.8.0 or ~> 1.9.0 or ~> 1.10.4 or ~> 1.11.0", runtime: false},
      {:shoehorn, "~> 0.9.1"},
      {:ring_logger, "~> 0.11.0"},
      {:toolshed, "~> 0.4.0"},
      {:vintage_net, "~> 0.13"},
      {:vintage_net_ethernet, "~> 0.11"},
      {:vintage_net_wifi, "~> 0.12"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.13.0", targets: @all_targets},
      {:nerves_pack, "~> 0.7.0", targets: @all_targets},

      # Dependencies for specific targets
      # NOTE: It's generally low risk and recommended to follow minor version
      # bumps to Nerves systems. Since these include Linux kernel and Erlang
      # version updates, please review their release notes in case
      # changes to your application are needed.
      {:nerves_system_rpi4, "~> 1.19", runtime: false, targets: :rpi4},
      {:kiosk_system_rpi4, "~> 0.2.0", runtime: false, targets: :rpi4_kiosk},
      {:nerves_system_x86_64, "~> 1.19", runtime: false, targets: :x86_64}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind open_boss", "esbuild open_boss"],
      "assets.deploy": [
        "tailwind open_boss --minify",
        "esbuild open_boss --minify",
        "phx.digest"
      ]
    ]
  end

  defp release do
    [
      overwrite: true,
      # Erlang distribution is not started automatically.
      # See https://hexdocs.pm/nerves_pack/readme.html#erlang-distribution
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end
end
