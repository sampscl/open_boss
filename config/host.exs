import Config

if config_env() != :test do
  config :open_boss, OpenBoss.Network, implementation: OpenBoss.Host.Network
end

config :open_boss, OpenBoss.Displays, implementation: OpenBoss.Host.Displays
config :open_boss, OpenBoss.Boot, implementation: OpenBoss.Host.Boot
config :open_boss, OpenBoss.System, implementation: OpenBoss.Host.System

config :vintage_net,
  resolvconf: "/dev/null",
  persistence: VintageNet.Persistence.Null

# Network wizard on startup
config :open_boss, OpenBoss.Network, wizard_file: "./start_vintage_net_wizard"
