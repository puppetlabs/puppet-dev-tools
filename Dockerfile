FROM ruby:2.5.7-slim-buster as base

ARG VCS_REF
ARG GH_USER=puppetlabs

LABEL org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/${GH_USER}/puppet-dev-tools"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq \
  && apt-get install -y apt-utils \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends gcc git gnupg2 make ruby-dev wget \
  && wget https://apt.puppet.com/puppet-tools-release-buster.deb \
  && dpkg -i puppet-tools-release-buster.deb \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends pdk \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

# Install dependent gems
RUN mkdir /setup
WORKDIR /setup
ADD Gemfile* /setup/
RUN gem install bundler \
  && bundle config set system 'true' \
  && bundle install --jobs=3 \
  && rm -f /root/.bundle/config

COPY Rakefile /Rakefile

RUN mkdir /repo
WORKDIR /repo

FROM base AS gosu

## Add gosu for CD for PE agent installation uid changes
ENV GOSU_VERSION 1.11
RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
  # verify the signature
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg2 --keyserver ipv4.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg2 --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  # verify that the binary works
  && gosu nobody true;
# End CD for PE agent requirements

FROM base AS main
