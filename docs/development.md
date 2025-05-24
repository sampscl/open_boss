# Development

## TODO

Urgent

- [ ] Network config in UI
- [ ] On-screen keyboard for pi kiosk
- [ ] Installation system for less technical users
- [ ] Adjust the device code to be more testable and write tests
- [ ] Alarm or alert system for when the time series device data diverges "too far"
- [x] Bug in history live chart that causes re-rendering artifacts
- [x] Fix existing tests
- [x] Elixir release for the app
- [x] UI timer for "last updated xxx ago..."
- [x] Tests for the phoenix-y parts
- [x] Add the `Cooks` context
- [x] Time series data for cooks

Not So Urgent

- [x] Virtual field in devices to support offline/online flag
- [ ] Support devices other than Egg Genius
- [x] Reorganize documentation
- [x] Stop Cook button for quick, common, change to a cook
- [x] Some sort of automated installer or instructions
- [x] Update the main app to be less "here's you're phoenix skeleton" and more "here's Open Boss"
- [x] Better github integration
- [x] UI graphs for time series device data

## Development Environment

1. Clone [OpenBoss](https://github.com/sampscl/open_boss.git).
2. Install the [ASDF](https://asdf-vm.com/guide/getting-started.html) version manager
3. Install tool dependencies

- Homebrew

```shell
# Note: if you are on MacOS, you will need XCode or gcc also
brew install openssl ncurses
```

- Ubuntu & other Debian-derived (incl. Raspberry Pi OS)

```shell
sudo apt-get install -y build-essential make autoconf libssl-dev libncurses-dev
```

4. Add plugins for ASDF and install the tools:

```shell
cd open_boss
asdf plugin-add elixir
asdf plugin-add erlang
asdf plugin-add nodejs
asdf install
```

5. One-time Elixir and Erlang language setup

```shell
mix archive.install hex nerves_bootstrap
mix local.hex
mix local.rebar
```

6. Get deps and make sure tests run successfully

```shell
mix deps.get
mix test
```

7. Build static assets (only needed when they change)

```shell
mix assets.deploy
```

## Running Locally

Nerves uses `MIX_TARGET=host` to allow standard Elixir development, but eventually the code
should be tested on the target. There is a good deal of interplay between the files in
`config/*.exs` for this; but in general, you insert a micro SD card into your laptop
and run:

```shell
MIX_ENV=prod MIX_TARGET=rpi4 mix do deps.get, firmware, burn
```

For the koisk build, which is meant to work with the Pi Touchscreen, use:

```shell
MIX_ENV=prod MIX_TARGET=rpi4_kiosk mix do deps.get, firmware, burn
```

Once you have a working target device, you can build and update the firmware remotely
in one step with:

```shell
MIX_TARGET=rpi4_kiosk MIX_ENV=prod "$SHELL" -c 'mix firmware && ./upload.sh open-boss.local'
```

## Running in QEMU

https://github.com/nerves-project/nerves_system_x86_64?tab=readme-ov-file#running-in-qemu

And upgrading works:

```shell
MIX_TARGET=x86_64 MIX_ENV=prod SSH_OPTIONS="-p 10022" ./upload.sh localhost
```

## VintageNet

Example output from `VintegeNet.get_by_prefix([])` on a raspberry pi 4:

```elixir
  [
    {["available_interfaces"], ["wlan0"]},
    {["connection"], :internet},
    {["interface", "eth0", "config"],
    %{type: VintageNetEthernet, ipv4: %{method: :dhcp}}},
    {["interface", "eth0", "connection"], :disconnected},
    {["interface", "eth0", "hw_path"], "/devices/platform/scb/fd580000.ethernet"},
    {["interface", "eth0", "lower_up"], false},
    {["interface", "eth0", "mac_address"], "dc:a6:32:22:07:ff"},
    {["interface", "eth0", "present"], true},
    {["interface", "eth0", "state"], :configured},
    {["interface", "eth0", "type"], VintageNetEthernet},
    {["interface", "lo", "addresses"],
    [
      %{
        scope: :host,
        netmask: {65535, 65535, 65535, 65535, 65535, 65535, 65535, 65535},
        family: :inet6,
        address: {0, 0, 0, 0, 0, 0, 0, 1},
        prefix_length: 128
      },
      %{
        scope: :host,
        netmask: {255, 0, 0, 0},
        family: :inet,
        address: {127, 0, 0, 1},
        prefix_length: 8
      }
    ]},
    {["interface", "lo", "hw_path"], "/devices/virtual"},
    {["interface", "lo", "lower_up"], true},
    {["interface", "lo", "mac_address"], "00:00:00:00:00:00"},
    {["interface", "lo", "present"], true},
    {["interface", "usb0", "addresses"],
    [
      %{
        scope: :universe,
        netmask: {255, 255, 255, 252},
        family: :inet,
        address: {172, 31, 222, 217},
        prefix_length: 30
      }
    ]},
    {["interface", "usb0", "config"],
    %{type: VintageNetDirect, vintage_net_direct: %{}}},
    {["interface", "usb0", "connection"], :disconnected},
    {["interface", "usb0", "hw_path"],
    "/devices/platform/soc/fe980000.usb/gadget.0"},
    {["interface", "usb0", "lower_up"], false},
    {["interface", "usb0", "mac_address"], "d2:4a:4b:d2:57:c4"},
    {["interface", "usb0", "present"], true},
    {["interface", "usb0", "state"], :configured},
    {["interface", "usb0", "type"], VintageNetDirect},
    {["interface", "wlan", "config"],
    %{
      type: VintageNetWiFi,
      ipv4: %{method: :disabled},
      vintage_net_wifi: %{networks: []}
    }},
    {["interface", "wlan", "connection"], :disconnected},
    {["interface", "wlan", "state"], :retrying},
    {["interface", "wlan", "type"], VintageNetWiFi},
    {["interface", "wlan0", "addresses"],
    [
      %{
        scope: :universe,
        netmask: {65535, 65535, 65535, 65535, 0, 0, 0, 0},
        family: :inet6,
        address: {64786, 22728, 42039, 39756, 56998, 13055, 65058, 2048},
        prefix_length: 64
      },
      %{
        scope: :universe,
        netmask: {255, 255, 255, 0},
        family: :inet,
        address: {192, 168, 86, 22},
        prefix_length: 24
      },
      %{
        scope: :link,
        netmask: {65535, 65535, 65535, 65535, 0, 0, 0, 0},
        family: :inet6,
        address: {65152, 0, 0, 0, 56998, 13055, 65058, 2048},
        prefix_length: 64
      }
    ]},
    {["interface", "wlan0", "config"],
    %{
      type: VintageNetWiFi,
      ipv4: %{method: :dhcp},
      vintage_net_wifi: %{
        networks: [
          %{
            mode: :infrastructure,
            psk: "5703F492927F161B20E5B9AC14582D4988320910519F5A41DF81A0B626EF3F80",
            ssid: "Pluto",
            key_mgmt: :wpa_psk
          }
        ]
      }
    }},
    {["interface", "wlan0", "connection"], :internet},
    {["interface", "wlan0", "dhcp_options"],
    %{
      broadcast: {192, 168, 86, 255},
      domain: "lan",
      ip: {192, 168, 86, 22},
      mask: 24,
      dns: [{192, 168, 86, 1}],
      hostname: "open-boss-9d49",
      siaddr: {192, 168, 86, 1},
      subnet: {255, 255, 255, 0},
      router: [{192, 168, 86, 1}],
      lease: 86400,
      renewal_time: 43200,
      rebind_time: 75600,
      serverid: {192, 168, 86, 1}
    }},
    {["interface", "wlan0", "hw_path"],
    "/devices/platform/soc/fe300000.mmcnr/mmc_host/mmc1/mmc1:0001/mmc1:0001:1"},
    {["interface", "wlan0", "lower_up"], true},
    {["interface", "wlan0", "mac_address"], "dc:a6:32:22:08:00"},
    {["interface", "wlan0", "present"], true},
    {["interface", "wlan0", "state"], :configured},
    {["interface", "wlan0", "type"], VintageNetWiFi},
    {["interface", "wlan0", "wifi", "access_points"],
    [
      %VintageNetWiFi.AccessPoint{
        bssid: "22:7f:88:1c:53:79",
        frequency: 2437,
        band: :wifi_2_4_ghz,
        channel: 6,
        signal_dbm: -34,
        signal_percent: 93,
        flags: [:wpa2_psk_ccmp, :wpa2, :psk, :ccmp, :ess],
        ssid: ""
      },
      %VintageNetWiFi.AccessPoint{
        bssid: "5e:ba:ef:e7:98:89",
        frequency: 5745,
        band: :wifi_5_ghz,
        channel: 149,
        signal_dbm: -59,
        signal_percent: 88,
        flags: [:wpa2_psk_ccmp, :wpa2, :psk, :ccmp, :wps, :ess, :p2p],
        ssid: "DIRECT-89-HP M283 LaserJet"
      },
      %VintageNetWiFi.AccessPoint{
        bssid: "90:ca:fa:98:21:fe",
        frequency: 2437,
        band: :wifi_2_4_ghz,
        channel: 6,
        signal_dbm: -40,
        signal_percent: 89,
        flags: [:wpa2_psk_ccmp, :wpa2, :psk, :ccmp, :ess],
        ssid: "Pluto"
      },
      %VintageNetWiFi.AccessPoint{
        bssid: "90:ca:fa:98:22:02",
        frequency: 5745,
        band: :wifi_5_ghz,
        channel: 149,
        signal_dbm: -46,
        signal_percent: 99,
        flags: [:wpa2_psk_ccmp, :wpa2, :psk, :ccmp, :ess],
        ssid: "Pluto"
      },
      %VintageNetWiFi.AccessPoint{
        bssid: "90:ca:fa:98:39:6e",
        frequency: 2462,
        band: :wifi_2_4_ghz,
        channel: 11,
        signal_dbm: -50,
        signal_percent: 79,
        flags: [:wpa2_psk_ccmp, :wpa2, :psk, :ccmp, :ess],
        ssid: "Pluto"
      },
      %VintageNetWiFi.AccessPoint{
        bssid: "90:ca:fa:98:39:72",
        frequency: 5745,
        band: :wifi_5_ghz,
        channel: 149,
        signal_dbm: -54,
        signal_percent: 93,
        flags: [:wpa2_psk_ccmp, :wpa2, :psk, :ccmp, :ess],
        ssid: "Pluto"
      },
      %VintageNetWiFi.AccessPoint{
        bssid: "90:ca:fa:98:3e:00",
        frequency: 2412,
        band: :wifi_2_4_ghz,
        channel: 1,
        signal_dbm: -35,
        signal_percent: 93,
        flags: [:wpa2_psk_ccmp, :wpa2, :psk, :ccmp, :ess],
        ssid: "Pluto"
      },
      %VintageNetWiFi.AccessPoint{
        bssid: "90:ca:fa:98:3e:04",
        frequency: 5745,
        band: :wifi_5_ghz,
        channel: 149,
        signal_dbm: -38,
        signal_percent: 100,
        flags: [:wpa2_psk_ccmp, :wpa2, :psk, :ccmp, :ess],
        ssid: "Pluto"
      },
      %VintageNetWiFi.AccessPoint{
        bssid: "f8:f0:05:6d:57:31",
        frequency: 2462,
        band: :wifi_2_4_ghz,
        channel: 11,
        signal_dbm: -53,
        signal_percent: 75,
        flags: [:wpa_psk_ccmp_tkip, :wpa2_psk_ccmp_tkip, :wpa, :psk, :ccmp,
          :tkip, :wpa2, :psk, :ccmp, :tkip, :wps, :ess],
        ssid: "sparkmeter-N000356"
      }
    ]},
    {["interface", "wlan0", "wifi", "clients"], []},
    {["interface", "wlan0", "wifi", "current_ap"],
    %VintageNetWiFi.AccessPoint{
      bssid: "90:ca:fa:98:3e:00",
      frequency: 2412,
      band: :wifi_2_4_ghz,
      channel: 1,
      signal_dbm: -35,
      signal_percent: 93,
      flags: [:wpa2_psk_ccmp, :wpa2, :psk, :ccmp, :ess],
      ssid: "Pluto"
    }},
    {["name_servers"], [%{address: {192, 168, 86, 1}, from: ["wlan0"]}]}
  ]
```

## Reverse Engineered Protocol

- Devices self-identify on the network with mDNS as `_flameboss._tcp.local`
- Send a HTTP GET request to `/switch` to cause the device to enter "Flame Boss Protocol"; it is currently unknown what this
  really does, but the official iOS app does it and so shall Open Boss
- MQTT is used as a pub/sub message bus
- The MQTT topics are `flameboss/<DEVICE_SERIAL_NUMBER>/...`
- Temperatures are degrees celsius \* 10, so 1489 is 148.9 degrees C
- Temperature values range from -32767 to 32768 so it's probably a 16-bit integer
- Blower values are percentage \* 100, so 10000 is 100%
- Publish to `flameboss/<DEVICE_SERIAL_NUMBER>/recv`
- Receive from `flameboss/<DEVICE_SERIAL_NUMBER>/send`, though there are other active topics
- Data payloads are JSON
- The data payload seems to always have a `name` key that identifies the shape and purpose of the payload
- The temps array looks like this:

```raw
[-32767,200,-32767,-32767]
                   ^^^^^^ probably meat probe #2
            ^^^^^^ probably pit probe #2
        ^^^ meat probe #1
 ^^^^^^ pit probe #1
```

### Known `recv` Messages

These are sent to the device (it is the receiver)

Set temp to `flameboss/<DEVICE_SERIAL_NUMBER>/recv`

```json
{
  "name": "set_temp",
  "value": 1489
}
```

### Known `send` Messages

These are received from the device (it is the sender)

Device ID from `flameboss/<DEVICE_SERIAL_NUMBER>/send/data`

```json
{
  "device_id": 0,
  "disabled": false,
  "hw_id": 10,
  "name": "id",
  "pin": 4257,
  "uid": "pOV8rD3sAAAAAAAAAAAAAA=="
}
```

Report temperatures from `flameboss/<DEVICE_SERIAL_NUMBER>/send/open`

```json
{
  "name": "temps",
  "cook_id": 0,
  "sec": 1732981927,
  "temps": [-32767, 200, -32767, -32767],
  "set_temp": 1489,
  "blower": 0
}
```
