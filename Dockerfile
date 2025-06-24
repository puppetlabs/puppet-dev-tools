# specifying the platform here allows builds to work
# correctly on Apple Silicon machines
FROM --platform=amd64 ruby:3.2.8-slim-bullseye as base

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
  && apt-get update -qq \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends curl libxml2-dev libxslt1-dev g++ gcc git gnupg2 make openssh-client ruby-dev wget zlib1g-dev libldap-2.4-2 libldap-common libssl-dev openssl cmake pkg-config \
  && wget https://apt.puppet.com/puppet-tools-release-bullseye.deb \
  && wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && dpkg -i puppet-tools-release-bullseye.deb \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends pdk=3.4.0.1-1bullseye powershell \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

RUN ln -s /bin/mkdir /usr/bin/mkdir

# Run tests on a module created with PDK 1.18.1 using the current PDK to pull in
# any other dependencies and then delete the 1.18.1 test module.
#
# Simply running "bundle install" against the module is not enough, 
# as PDK has further dependencies to pull in.
COPY testmod /testmod
RUN cd testmod \
  && pdk validate \
  && cd .. \
  && rm -rf testmod

RUN groupadd --gid 1001 puppetdev \
  && useradd --uid 1001 --gid puppetdev --create-home puppetdev

# Prep for non-root user
RUN gem install bundler -v 2.6.9 \
  && chown -R puppetdev:puppetdev /usr/local/bundle \
  && mkdir /setup \
  && chown -R puppetdev:puppetdev /setup \
  && mkdir /repo \
  && chown -R puppetdev:puppetdev /repo

# Switch to a non-root user for everything below here
USER puppetdev

# Install dependent gems
WORKDIR /setup
ADD Gemfile* /setup/
COPY Rakefile /Rakefile

RUN bundle config set system 'true' \
  && bundle config set jobs 3 \
  && bundle install \
  && rm -f /home/puppetdev/.bundle/config \
  && rm -rf /usr/local/bundle/gems/puppet-8.*.0/spec

WORKDIR /repo

FROM base AS rootless

FROM base AS main
USER root
