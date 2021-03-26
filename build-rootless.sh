#!/usr/bin/env bash

set -e

GH_USER=${1:-puppetlabs}
DOCKER_IMAGE=${2:-'puppet-dev-tools:latest-rootless'}

docker build \
  --target rootless \
  -t ${DOCKER_IMAGE} \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  --build-arg GH_USER=${GH_USER} \
  -f Dockerfile .
