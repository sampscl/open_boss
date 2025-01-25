# OpenBoss

An open source Elixir application to control Flame Boss and white labeled Flame
Boss controllers like the Egg Genius.

Ever try to cook on a major holiday like Thanksgiving in the US and discover that
your cloud-connected BBQ controller isn't working very well? Things like network
disconnects, severely delayed notifications, inability to control the temperature
settings, and so on? Me too.

This happens because FlameBoss' cloud services are overwhelmed with the number of
simultaneous users. Cloud services cost money (a shocking amount of it), and these
controllers do not require a paid subscription (Yay! Much love for this choice!),
but that also means that FlameBoss has to pay for the cloud services through
equipment sales (why your device costs so much), and potentially through selling
information collected from their users (Boooooo! I hope not.).

The fine product and engineering teams at Flame Boss clearly knew this could be a
problem and wanted their customers to have an alternative. In the Big Green Egg
iOS app, this is "local" and "direct" mode. Those modes have limited functionality
compared to "cloud" mode, but they do allow you to control your device.

Open Boss uses direct mode, and provides (or will eventually...) the features
missing from cloud mode. It does this 100% locally and never needs an internet
connection. If you want timestamps to be accurate, you probably want internet
for that...but Open Boss will work just fine without it.

- [Installation](./docs/installation.md#installation)
- [Development](./docs/development.md#development)

## What Works Today

- Discovery of Flame Boss devices on the local network via mDNS
- Basic control of Egg Genius, maybe others like the Flame Boss 400
- Cook tracking and history

OpenBoss works by running software on the same network as the Flame Boss device(s),
discovering them using mDNS, and connecting to each using MQTT. Internet connectivity
is not required. OpenBoss presents a web-based interface to control the devices, manage
"cooks" (a session of cooking food, not a group of people cooking things in a kitchen),
and provide feedback regarding cooking progress. It is lightweight, requiring very
little CPU and typically < 100MB of memory, making Raspberry Pi or BeagleBone viable
host platforms. It should run on any system capable of running Erlang.
