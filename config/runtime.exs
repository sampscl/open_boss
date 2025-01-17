import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/open_boss start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if config_env() == :prod or is_binary(System.get_env("PHX_SERVER")) do
  config :open_boss, OpenBossWeb.Endpoint, server: true
end

if config_env() == :prod do
  # Determine location of the database in prod
  database =
    with nil <- System.get_env("DB_DIR") do
      case :os.type() do
        {:unix, :darwin} ->
          # macos
          Path.expand("~/Library/Application Support/Open Boss/db.sqlite3")

        {:unix, _} ->
          # likely linux of some kind
          "/var/lib/open_boss/db.sqlite3"

        _unsupported ->
          # windows probably, maybe others
          raise "Unsupported Operating System"
      end
    end

  # Config database
  config :open_boss, OpenBoss.Repo,
    database: database,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :open_boss, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  # config :open_boss, OpenBossWeb.Endpoint,
  #   url: [host: host, port: 443, scheme: "https"],
  #   http: [
  #     # Enable IPv6 and bind on all interfaces.
  #     # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
  #     # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
  #     # for details about using IPv6 vs IPv4 and loopback vs public addresses.
  #     ip: {0, 0, 0, 0, 0, 0, 0, 0},
  #     port: port
  #   ],
  #   secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  config :open_boss, OpenBossWeb.Endpoint,
    url: [host: host, port: port, scheme: "https"],
    https: [
      ip: {0, 0, 0, 0},
      port: 443,
      cipher_suite: :strong,
      keyfile: System.fetch_env!("KEYFILE"),
      certfile: System.fetch_env!("CERTFILE")
    ],
    secret_key_base: secret_key_base

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
