#!/usr/bin/env bash

set -eux

mkdir -p bin

GOPATH=$(mktemp -d --tmpdir go.XXXXXX)
export GOPATH
export PATH="$GOPATH/bin:$PATH"
# cleanup, not really necessary on platform but nice when testing locally
trap 'chmod -R +w "$GOPATH" && rm -rf "$GOPATH"' EXIT

(cd ./cmd/config && go build -o ../../bin/config .)

# unset GO111MODULE as `docker_auth` doesn't support it yet
unset GO111MODULE

outdir=${GOPATH}/src/github.com/cesanta/docker_auth
git clone -b 1.4.0 https://github.com/cesanta/docker_auth.git "$outdir"
(
	cd "$outdir/auth_server" &&
		make deps &&
		make generate &&
		make &&
		file auth_server
)

cp -a "$outdir/auth_server/auth_server" bin/
