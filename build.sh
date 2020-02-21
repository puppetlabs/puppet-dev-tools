#!/bin/bash

SHA=''

function build() {
  SHA=$(docker build -t $1 -f $2 . | grep "^Successfully built" | awk '{ print $3 }')
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
  done < <(docker run --rm puppet/puppet-dev-tools:latest rake -f /Rakefile -T |tr -s ' ')
}

echo -n "Building base image..."
build puppet/puppet-dev-tools:latest Dockerfile
echo $SHA

echo "Updating rake tasks in README.md..."
update_readme

echo -n "Building gosu image..."
build puppet/puppet-dev-tools:gosu gosu/Dockerfile
echo $SHA
