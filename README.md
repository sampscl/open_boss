# OpenBoss

An open source [licensed](LICENSE.txt) Elixir application to control Flame Boss
and white labeled Flame Boss controllers like the Egg Genius (which happens to
be the device the author owns and used to reverse the MQTT protocol).

## What Works Today

- Discovery of Flame Boss devices on the local network via mDNS
- Basic control of Egg Genius, maybe others like the Flame Boss 400
- Cook tracking and history

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
- [ ] Stop Cook button for quick, common, change to a cook
- [ ] Virtual field in devices to support offline/online flag
- [ ] Some sort of automated installer or instructions
- [x] Update the main app to be less "here's you're phoenix skeleton" and more "here's Open Boss"
- [ ] Support devices other than Egg Genius
- [ ] Figure out "Raspberry Pi with Kiosk Mode"; separate project or embedded here?
- [x] Better github integration
- [ ] UI graphs for time series device data

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
