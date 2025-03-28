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
