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
    ca-certificates

RUN gem install --no-ri --no-rdoc r10k \
    pdk \
    puppet:5.3.3 \
    rubocop \
    puppetlabs_spec_helper \
    puppet-lint \
    onceover \
    rest-client

## Install ra10ke from source until https://github.com/voxpupuli/ra10ke/issues/28
## is released
RUN git clone https://github.com/voxpupuli/ra10ke.git /tmp/ra10ke\
    && cd /tmp/ra10ke \
    && gem build ra10ke.gemspec \
    && gem install ra10ke-0.4.0.gem

COPY Rakefile /Rakefile

RUN mkdir -p /repo
WORKDIR /repo


# CD for PE agent requirements
## Compile an older version of curl for support for the Distelli agent
ENV CURL_VERSION 7.55.0
RUN wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.gz \
    && tar -xzf curl-$CURL_VERSION.tar.gz \
    && cd curl-$CURL_VERSION \
    && ./configure \
    && make \
    && make install \
    && rm -rf /curl-$CURL_VERSION.tar.gz /curl-$CURL_VERSION

## Support for the CD for PE agent
RUN adduser distelli -D
## Add gosu for CD for PE agent installation uid changes
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
    rm -fr "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    \
    chmod +x /usr/local/bin/gosu; \
    # verify that the binary works
    gosu nobody true; \
    \
    apk del .gosu-deps
# End CD for PE agent requirements
