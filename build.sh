#!/bin/bash
set -eu
VERSION=2.4.22

docker buildx build --push --builder=buildx-multi-arch --platform=linux/amd64 -t "mochoa/dockercloud-haproxy:${VERSION}" .
