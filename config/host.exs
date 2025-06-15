import Config

if config_env() != :test do
  config :open_boss, OpenBoss.Network, implementation: OpenBoss.Host.Network
  config :open_boss, OpenBoss.System, implementation: OpenBoss.Host.System
end

config :open_boss, OpenBoss.Displays, implementation: OpenBoss.Host.Displays
config :open_boss, OpenBoss.Boot, implementation: OpenBoss.Host.Boot

config :vintage_net,
  resolvconf: "/dev/null",
  persistence: VintageNet.Persistence.Null
