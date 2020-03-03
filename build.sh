#!/bin/bash

set -e

GH_USER=${1:-puppetlabs}

SHA=''

function build() {
  SHA=$(docker build --target $1 -t $2 --build-arg VCS_REF=$(git rev-parse --short HEAD) --build-arg GH_USER=$3 -f Dockerfile . | grep "^Successfully built" | awk '{ print $3 }')
}

function update_readme() {
  sed -i '/### Rake Tasks/,$d' README.md
  echo '### Rake Tasks' >> README.md
  echo >> README.md
  echo '| Command | Description |' >> README.md
  echo '| ------- | ----------- |' >> README.md
  while read -r line; do
    f1=$(echo $line |cut -d '#' -f1)
    f2=$(echo $line |cut -d '#' -f2-)
    echo "| $f1 | $f2 |" >> README.md
  done < <(docker run --rm puppet-dev-tools:latest rake -f /Rakefile -T |tr -s ' ')
}

echo -n "Building base image..."
build base puppet-dev-tools:latest $GH_USER
echo $SHA

echo "Updating rake tasks in README.md..."
update_readme

echo -n "Building gosu image..."
build gosu puppet-dev-tools:gosu $GH_USER
echo $SHA
