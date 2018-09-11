FROM centos:7

ENV RUBY_MAJOR 2.4
ENV RUBY_VERSION 2.4.1
ENV BUNDLER_VERSION 1.15.4
ENV RUBYGEMS_VERSION 2.6.13

RUN yum makecache \
    && yum install -y \
      git \
      make \
      gcc \
      gcc-c++ \
      autoconf \
      automake \
      patch \
      readline \
      readline-devel \
      zlib \
      zlib-devel \
      libyaml-devel \
      libffi-devel \
      openssl-devel \
    && rpm -i https://pm.puppet.com/cgi-bin/pdk_download.cgi?arch=x86_64\&dist=el\&rel=7\&ver=latest


RUN curl -O https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz \
    && tar xzf ruby-$RUBY_VERSION.tar.gz -C /usr/src \
    && cd /usr/src/ruby-$RUBY_VERSION \
    && CFLAGS="-O3 -fPIC -fno-strict-aliasing" ./configure --disable-install-doc --enable-shared --enable-pthread \
    && make \
    && make install \
    && cd / \
    && rm -rf /usr/src/ruby-$RUBY_VERSION \
    && rm -rf /ruby-$RUBY_VERSION.tar.gz

RUN gem install --no-ri --no-rdoc r10k \
      puppet \
      puppetlabs_spec_helper \
      puppet-lint \
      onceover \
      rest-client

COPY Rakefile /Rakefile

RUN mkdir -p /repo
WORKDIR /repo
