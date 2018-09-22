FROM ruby:2.4.4-alpine

RUN apk update && apk add \
      git \
      make \
      gcc \
      g++ \
      autoconf \
      automake \
      patch \
      readline \
      readline-dev \
      zlib \
      zlib-dev \
      libffi-dev \
      openssl-dev \
      libgcc \
      bash \
      wget \
      curl \
      ca-certificates

# Support for the CD for PE agent
RUN adduser distelli -D
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	apk add --no-cache --virtual .gosu-deps \
		dpkg \
		gnupg \
		openssl \
	; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
  # verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
  # verify that the binary works
	gosu nobody true; \
	\
	apk del .gosu-deps

RUN gem install --no-ri --no-rdoc r10k \
      pdk \
      puppet \
      puppetlabs_spec_helper \
      puppet-lint \
      onceover \
      rest-client

COPY Rakefile /Rakefile

RUN mkdir -p /repo
WORKDIR /repo
