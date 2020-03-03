FROM ruby:2.5.7-slim-buster

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq \
  && apt-get install -y apt-utils \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends gcc git gnupg2 make ruby-dev wget openssh-client \
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
  && bundle install --jobs=3

COPY Rakefile /Rakefile

RUN mkdir /repo
WORKDIR /repo
