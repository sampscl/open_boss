# Installation

## Keys and certs (all platforms)

If you do not have your own server keys and certs, OpenBoss can generate self-signed ones. If you
plan on exposing your OpenBoss server to the world (or to friends and family) and don't want them
dealing with "this website is not trusted" warnings in their browsers, you should get real certs
or show your tech-savvy crowd how to trust the root CA generated here. That's all beyond the scope
of this README, so set up your development environment and here's how to make self-signed ones:

```shell
ROOT_CA_SUBJECT_RDN='/C=AU/ST=NSW/L=Sydney/O=PhilipShermanDentistry/CN="P. Sherman Root CA"' \
SUBJECT_RDN='/C=AU/ST=NSW/L=Sydney/O=PhilipShermanDentistry/CN="P. Sherman"' \
SUBJECT_AN=`hostname` \
  mix open_boss.build_self_signed_keys
```

## Systemd and Docker (e.g. Ubuntu)

1. Set up [developmenmt](./development.md#development-environment) environmnent as pre-built images are not (yet) available
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

5. Create docker compose file

- If you used your own certs or set a different `SUBJECT_AN`, change `PHX_HOST`
- The default compose file works with the self-signed cert process, but may need tweaking if you brought your own certs

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
