import Config

# Test env lists all devices
config :open_boss, OpenBoss.Devices, list: :all
config :open_boss, OpenBoss.Devices.Manager, enable_mqtt: false

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
# Set database file
config :open_boss, OpenBoss.Repo,
  database: "priv/db/watering_can_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :open_boss, OpenBossWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "EhTPKEZs5RnuE+Rx7NP61EmVfCNNAv8ybqs9OftepkMsITVrUELgKXmtCVbbL9vT",
  server: false

# In test we don't send emails
config :open_boss, OpenBoss.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :debug

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
