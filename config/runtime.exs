import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

if config_env() == :prod do
  # Config database
  config :open_boss, OpenBoss.Repo,
    database: "/root/db.sqlite3",
    pool_size: 10

  # Hard code secret key base, as this is an embedded system and not really
  # meant to run in a cloud / server prod environment like a standard phoenix app
  secret_key_base = "rQUsriZ8++PjeCJAa9oANfHoyYn3Aq/zYyNpGuNRsN0N4jhxV/DiCmfrDjP+3wL9"

  # Get the actual hostname from the device, or fall back to a default
  host = System.get_env("HOSTNAME", "open-boss.local")
  port = 80

  config :open_boss, OpenBossWeb.Endpoint,
    url: [host: host, port: port, scheme: "http"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    cache_static_manifest: "priv/static/cache_manifest.json",
    check_origin: false,
    # Start the server since we're running in a release instead of through `mix`
    server: true,
    # Code Reloader and watchers cannot be used on target
    # because the root filesystem is read-only
    code_reloader: true,
    watchers: []

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  # config :open_boss, OpenBossWeb.Endpoint,
  #   url: [host: host, port: port, scheme: "https"],
  #   https: [
  #     ip: {0, 0, 0, 0},
  #     port: 443,
  #     cipher_suite: :strong,
  #     keyfile: System.fetch_env!("KEYFILE"),
  #     certfile: System.fetch_env!("CERTFILE")
  #   ],
  #   secret_key_base: secret_key_base

  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :open_boss, OpenBossWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end
