# OpenBoss

An open source [licensed](LICENSE.txt) Elixir application to control Flame Boss
and white labeled Flame Boss controllers like the Egg Genius (which happens to
be the device the author owns and used to reverse the MQTT protocol).

OpenBoss works by running software on the same network as the Flame Boss device(s),
discovering them using mDNS, and connecting to each using MQTT. Internet connectivity
is not required. OpenBoss presents a web-based interface to control the devices, manage
"cooks" (a session of cooking food, not a group of people cooking things in a kitchen),
and provide feedback regarding cooking progress. It is lightweight, requiring very
little CPU and typically < 100MB of memory, making Raspberry Pi or BeagleBone viable
host platforms. It should run on any system capable of running Erlang.

## Table of Contents

[What Works Today](#what-works-today)
[Development](./docs/development.md#development)
[Installation](./docs/installation.md#installation)

## What Works Today

- Discovery of Flame Boss devices on the local network via mDNS
- Basic control of Egg Genius, maybe others like the Flame Boss 400
- Cook tracking and history
