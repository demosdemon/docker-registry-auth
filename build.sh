#!/usr/bin/env bash

set -eux

mkdir -p bin

go build -o bin/config ./cmd/config

GOPATH=$(mktemp -d --tmpdir go.XXXXXX)
export GOPATH
export PATH="$GOPATH/bin:$PATH"
# cleanup, not really necessary on platform but nice when testing locally
trap 'rm -rf "$GOPATH"' EXIT

# unset GO111MODULE as `docker_auth` doesn't support it yet
unset GO111MODULE

outdir=${GOPATH}/src/github.com/cesanta/docker_auth
git clone https://github.com/cesanta/docker_auth.git "$outdir"
(
	cd "$outdir" &&
		git checkout 'b89dec9a4f0098fb0f71d9b94e44d1710c1fe5cf' &&
		cd "auth_server" &&
		make deps &&
		make generate &&
		make &&
		file auth_server
)

cp -a "$outdir/auth_server/auth_server" bin/