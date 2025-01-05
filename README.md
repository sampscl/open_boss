# OpenBoss

An open source [licensed](LICENSE.txt) Elixir application to control Flame Boss
and white labeled Flame Boss controllers like the Egg Genius (which happens to
be the device the author owns and used to reverse the MQTT protocol).

## What Works Today

- Discovery of Flame Boss devices on the local network via mDNS
- Basic control of Egg Genius, maybe others like the Flame Boss 400
- Cook tracking and history

## Installation

### Keys and certs (all platforms)

If you do not have your own server keys and certs, OpenBoss can generate self-signed ones. If you
plan on exposing your OpenBoss server to the world (or to friends and family) and don't want them
dealing with "this website is not trusted" warnings in their browsers, you should get real certs
or show your tech-savvy crowd how to trust the root CA generated here. That's all beyond the scope
of this README, so here's how to make self-signed ones:

```shell
ROOT_CA_SUBJECT_RDN='/C=AU/ST=NSW/L=Sydney/O=PhilipShermanDentistry/CN="P. Sherman Root CA"' \
SUBJECT_RDN='/C=AU/ST=NSW/L=Sydney/O=PhilipShermanDentistry/CN="P. Sherman"' \
SUBJECT_AN=`hostname` \
  mix open_boss.build_self_signed_keys
```

### Systemd and Docker (e.g. Ubuntu)

1. Set up [developmenmt](#Development) environmnent as pre-built images are not (yet) available
2. Install [docker](https://www.docker.com) for your OS; the Docker Desktop is not necessary, only Docker Engine
3. Install javascript packages

```shell
cd assets
npm install
cd ..
```

4. Copy self-signed certificates and keys and install them; if you have your own keys and certs, use them here

```shell
sudo cp -v etc/ssl/certs/*.pem /etc/ssl/certs/
sudo cp -v etc/ssl/private/*.pem /etc/ssl/private/
```

5. Create docker compose file; if you used your own certs or set a different `SUBJECT_AN`, change `PHX_HOST`

```shell
PHX_HOST=`hostname` mix open_boss.build_compose
sudo mkdir -p /etc/docker/compose/open_boss
sudo cp -v etc/docker/compose/open_boss/docker-compose.yml /etc/docker/compose/open_boss
```

6. Build a OpenBoss docker image; be patient, this takes a few minutes

```shell
mix open_boss.build_image
```

7. Configure the service

```shell
sudo cp -v etc/systemd/system/docker-compose@.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now docker-compose@open_boss.service
# tail the logs for a few minutes to make sure things start up, ctrl-c to exit:
sudo journalctl -exfu docker-compose@open_boss.service
```

## TODO

Urgent

- [x] Fix existing tests
- [x] Elixir release for the app
- [ ] Adjust the device code to be more testable and write tests
- [x] UI timer for "last updated xxx ago..."
- [x] Tests for the phoenix-y parts
- [x] Add the `Cooks` context
- [x] Time series data for cooks
- [ ] Alarm or alert system for when the time series device data diverges "too far"

Not So Urgent

- [ ] Reorganize documentation
- [ ] Cross-platform docker image builds
- [ ] Docker registry for pre-built images
- [ ] Stop Cook button for quick, common, change to a cook
- [ ] Virtual field in devices to support offline/online flag
- [x] Some sort of automated installer or instructions
- [x] Update the main app to be less "here's you're phoenix skeleton" and more "here's Open Boss"
- [ ] Support devices other than Egg Genius
- [ ] Figure out "Raspberry Pi with Kiosk Mode"; separate project or embedded here?
- [x] Better github integration
- [ ] UI graphs for time series device data

## Development

1. Clone [OpenBoss](https://github.com/sampscl/open_boss.git).
2. Install the [ASDF](https://asdf-vm.com/guide/getting-started.html) version manager
3. Install tool dependencies

- Homebrew

```shell
# Note: if you are on MacOS, you will need XCode or gcc also
brew install openssl ncurses
```

- Ubuntu & other Debian-derived (incl. Raspberry PI OS)

```shell
sudo apt-get install -y build-essential make autoconf libssl-dev libncurses-dev
```

4. Add plugins for ASDF and install the tools:

```shell
cd open_boss
asdf plugin-add elixir
asdf plugin-add erlang
asdf plugin-add zig
asdf plugin-add nodejs
asdf install
```

5. Get deps and make sure tests run successfully

```shell
mix deps.get
mix test
```

## Reverse Engineered Protocol

- Devices self-identify on the network with mDNS as `_flameboss._tcp.local`
- Send a HTTP GET request to `/switch` to cause the device to enter "Flame Boss Protocol"; it is currently unknown what this
  really does, but the iOS app does it and so shall Open Boss
- MQTT is used as a pub/sub message bus
- The MQTT topics are `flameboss/<DEVICE_SERIAL_NUMBER>/...`
- Temperatures are degrees celsius \* 10, so 1489 is 148.9 degrees C
- Temperature values range from -32767 to 32768
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

## Development

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
