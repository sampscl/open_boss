import Config

# Network wizard on startup
config :open_boss, OpenBoss.Network, wizard_file: "/root/start_vintage_net_wizard"

# Timezone database
config :tzdata, :data_dir, "/root/"

config :open_boss, HelloLiveViewWeb.Endpoint,
  # Code Reloader and watchers cannot be used on target
  # because the root filesystem is read-only
  code_reloader: false,
  watchers: []

config :open_boss, OpenBoss.Network, implementation: OpenBoss.Target.Network
config :open_boss, OpenBoss.System, implementation: OpenBoss.Target.System

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger,
  backends: [RingLogger]

# Use shoehorn to start the main application. See the shoehorn
# library documentation for more control in ordering how OTP
# applications are started and handling failures.

config :shoehorn, init: [:nerves_runtime, :nerves_pack]

# Erlinit can be configured without a rootfs_overlay. See
# https://github.com/nerves-project/erlinit/ for more information on
# configuring erlinit.

config :nerves,
  erlinit: [
    hostname_pattern: "open-boss-%-.4s"
  ]

# Configure the device for SSH IEx prompt access and firmware updates
#
# * See https://hexdocs.pm/nerves_ssh/readme.html for general SSH configuration
# * See https://hexdocs.pm/ssh_subsystem_fwup/readme.html for firmware updates

if !System.get_env("GITHUB_ACTIONS") do
  keys =
    [
      Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
      Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
      Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
    ]
    |> Enum.filter(&File.exists?/1)

  if keys == [],
    do:
      Mix.raise("""
      No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
      log into the Nerves device and update firmware on it using ssh.
      See your project's target.exs for this error message.
      """)

  config :nerves_ssh,
    authorized_keys: Enum.map(keys, &File.read!/1)

  # Configure the network using vintage_net
  # See https://github.com/nerves-networking/vintage_net for more information
  config :vintage_net,
    regulatory_domain: "US",
    config: [
      {"usb0", %{type: VintageNetDirect}},
      {"eth0",
       %{
         type: VintageNetEthernet,
         ipv4: %{method: :dhcp}
       }},
      {"wlan0",
       %{
         type: VintageNetWiFi,
         vintage_net_wifi: %{
           networks: []
         },
         ipv4: %{method: :dhcp}
       }}
    ]
else
  #
  # CI builds create "blank" firmware that will be configured
  # by the user later from the UI. Until then, support logging
  # in and updating firmware via ssh without credentials
  #
  config :nerves_ssh,
    user_passwords: [
      {"open_boss", ""}
    ]

  #
  # CI builds set default WiFi in access point mode
  # with no password
  #
  config :vintage_net,
    regulatory_domain: "US",
    config: [
      {"usb0", %{type: VintageNetDirect}},
      {"eth0",
       %{
         type: VintageNetEthernet,
         ipv4: %{method: :dhcp}
       }},
      {"wlan0",
       %{
         type: VintageNetWiFi,
         vintage_net_wifi: %{
           networks: [
             %{
               mode: :ap,
               ssid: "open-boss",
               key_mgmt: :none
             }
           ]
         },
         ipv4: %{
           method: :static,
           address: "192.168.24.1",
           netmask: "255.255.255.0"
         },
         dhcpd: %{
           start: "192.168.24.10",
           end: "192.168.24.100",
           options: %{
             dns: ["1.1.1.1", "1.0.0.1"],
             subnet: "255.255.255.0",
             router: ["192.168.24.1"]
           }
         }
       }}
    ]
end

config :mdns_lite,
  # The `hosts` key specifies what hostnames mdns_lite advertises.  `:hostname`
  # advertises the device's hostname.local. For the official Nerves systems, this
  # is "nerves-<4 digit serial#>.local".  The `"nerves"` host causes mdns_lite
  # to advertise "nerves.local" for convenience. If more than one Nerves device
  # is on the network, it is recommended to delete "nerves" from the list
  # because otherwise any of the devices may respond to nerves.local leading to
  # unpredictable behavior.

  hosts: [:hostname],
  ttl: 120,

  # Advertise the following services over mDNS.
  services: [
    %{
      protocol: "http",
      transport: "tcp",
      port: 80
    },
    %{
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]

# Config MOTD
config :nerves_motd, logo: File.read!("priv/static/images/motd_logo.txt")

# specific target config
case Mix.target() do
  :rpi4_kiosk ->
    config :open_boss, OpenBoss.Displays, implementation: OpenBoss.Rpi4Kiosk.Displays
    config :open_boss, OpenBoss.Boot, implementation: OpenBoss.Rpi4Kiosk.Boot

  _ ->
    config :open_boss, OpenBoss.Displays, implementation: OpenBoss.Target.Displays
    config :open_boss, OpenBoss.Boot, implementation: OpenBoss.Target.Boot
end
