FROM hexpm/elixir:1.17.3-erlang-27.1.3-alpine-3.21.0 AS builder

ENV MIX_ENV=prod
ENV APP_NAME=open_boss
# Thank you tme_317! (https://elixirforum.com/t/cant-compile-elixir-phoenix-api-in-docker-build-step/56863/7)
# Workaround QEMU JIT issue building AMD64 on ARM64
ENV ERL_FLAGS="+JPperf true"

RUN apk update && \
  apk add --no-cache \
  libgcc \
  git \
  curl

WORKDIR /app
COPY . /app

RUN rm -rf _build deps

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get && \
  mix assets.deploy  && \
  mix release

FROM alpine:3.21.0

ENV MIX_ENV=prod
ENV APP_NAME=open_boss

RUN apk update && \
  apk add \
  --no-cache \
  openssl-dev \
  libstdc++ \
  ncurses

WORKDIR /app
COPY --from=builder /app/_build/${MIX_ENV}/rel/open_boss /app
CMD ["/app/bin/${APP_NAME}",  "start"]
