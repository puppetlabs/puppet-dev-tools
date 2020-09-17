#!/usr/bin/env bash

set -e

DOCKER_IMAGE=${1:-'puppet-dev-tools:el7'}

sed -i '/### Rake Tasks/,$d' README.md
echo '### Rake Tasks' >> README.md
echo >> README.md
echo '| Command | Description |' >> README.md
echo '| ------- | ----------- |' >> README.md
while read -r line; do
  f1=$(echo $line |cut -d '#' -f1)
  f2=$(echo $line |cut -d '#' -f2-)
  echo "| $f1 | $f2 |" >> README.md
done < <(docker run --rm ${DOCKER_IMAGE} rake -f /Rakefile -T |tr -s ' ')
