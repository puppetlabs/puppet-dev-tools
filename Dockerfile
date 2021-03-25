# specifying the platform here allows builds to work
# correctly on Apple Silicon machines
FROM --platform=amd64 ruby:2.7.2-slim-buster as base

ARG VCS_REF
ARG GH_USER=puppetlabs

LABEL org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/${GH_USER}/puppet-dev-tools"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq \
  && apt-get install -y locales \
  && sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen \
  && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get install -y apt-utils \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends curl libxml2-dev libxslt1-dev g++ gcc git gnupg2 make openssh-client ruby-dev wget zlib1g-dev \
  && wget https://apt.puppet.com/puppet-tools-release-buster.deb \
  && dpkg -i puppet-tools-release-buster.deb \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends pdk \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

RUN useradd cd4pe

# Install dependent gems
RUN mkdir /setup
WORKDIR /setup
ADD Gemfile* /setup/
RUN ln -s /bin/mkdir /usr/bin/mkdir

RUN gem install bundler \
  && bundle config set system 'true' \
  && bundle install --system --jobs=3 \
  && rm -f /root/.bundle/config

COPY Rakefile /Rakefile

RUN mkdir /repo
WORKDIR /repo

USER cd4pe

FROM base AS main
