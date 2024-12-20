# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :open_boss,
  ecto_repos: [OpenBoss.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure devices behavior
config :open_boss, OpenBoss.Devices, list: :live
config :open_boss, OpenBoss.Devices.Manager, enable_mqtt: true

# Configure sqlite
config :ecto_sqlite3,
  binary_id_type: :binary,
  uuid_type: :binary

# Configure database; leave the database file itself up to other config files
config :open_boss, OpenBoss.Repo,
  timeout: :infinity,
  synchronous: :full,
  locking_mode: :normal,
  journaling_mode: :wal,
  foreign_keys: :on,
  busy_timeout: 2_000,
  wal_auto_checkpoint: 500,
  stacktrace: true,
  pool_size: 10

# Configures the endpoint
config :open_boss, OpenBossWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: OpenBossWeb.ErrorHTML, json: OpenBossWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: OpenBoss.PubSub,
  live_view: [signing_salt: "Pk3jU7WV"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :open_boss, OpenBoss.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  open_boss: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  open_boss: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time [$level] $metadata $message\n",
  metadata: [:request_id, :mfa]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
