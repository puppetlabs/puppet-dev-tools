FROM centos:7

ENV RUBYPATH=/opt/puppetlabs/pdk/private/ruby/2.4.4/bin/
ENV PATH=$RUBYPATH:$PATH

RUN rpm -i https://pm.puppet.com/cgi-bin/pdk_download.cgi?arch=x86_64\&dist=el\&rel=7\&ver=latest

RUN echo PATH=$RUBYPATH:\$PATH >> /etc/bashrc

RUN yum makecache && yum install -y \
      git \
      make \
      gcc \
      gcc-c++ \
      autoconf \
      automake \
      openssh-client \
      patch \
      readline \
      readline-dev \
      zlib \
      zlib-devel \
      libffi-devel \
      libxml2-devel \
      openssl-devel \
      libgcc \
      bash \
      wget \
      ca-certificates \
    && gem install --no-ri --no-rdoc r10k \
      ra10ke \
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


## Support for the CD for PE agent
RUN adduser distelli

## Add gosu for CD for PE agent installation uid changes
ENV GOSU_VERSION 1.11
RUN set -ex; \
  curl -Lo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-i386"; \
  curl -Lo /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-i386.asc"; \
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
# End CD for PE agent requirements
