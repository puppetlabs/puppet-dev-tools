#!/bin/bash

SHA=''

function build() {
  SHA=$(docker build -t $1 -f $2 . | grep "^Successfully built" | awk '{ print $3 }')
}

echo -n "Building base image..."
build puppet/puppet-dev-tools:latest Dockerfile
echo $SHA

echo -n "Building gosu image..."
build puppet/puppet-dev-tools:gosu gosu/Dockerfile
echo $SHA

