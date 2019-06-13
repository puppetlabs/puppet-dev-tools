FROM centos:7

# Set up the paths for Ruby
ENV PATH=/opt/rh/rh-ruby24/root/usr/local/bin:/opt/rh/rh-ruby24/root/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/opt/rh/rh-ruby24/root/usr/local/lib64:/opt/rh/rh-ruby24/root/usr/lib64:=/opt/rh/rh-ruby24/root/usr/local/lib64
ENV MANPATH=/opt/rh/rh-ruby24/root/usr/local/share/man:/opt/rh/rh-ruby24/root/usr/share/man:
ENV X_SCLS=rh-ruby24
ENV XDG_DATA_DIRS=/opt/rh/rh-ruby24/root/usr/local/share:/opt/rh/rh-ruby24/root/usr/share:/usr/local/share:/usr/share
ENV PKG_CONFIG_PATH=/opt/rh/rh-ruby24/root/usr/local/lib64/pkgconfig:/opt/rh/rh-ruby24/root/usr/lib64/pkgconfig

# Install latest PDK and image dependencies
RUN rpm -i https://pm.puppet.com/cgi-bin/pdk_download.cgi?arch=x86_64\&dist=el\&rel=7\&ver=latest \
    && yum makecache && yum install -y \
      git \
      make \
      gcc \
      gcc-c++ \
      autoconf \
      automake \
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
      ca-certificates

#Set up Ruby 2.4. Must be separate from Ruby installed with PDK
RUN yum install -y centos-release-scl \
    && yum-config-manager --enable rhel-server-rhscl-7-rpms \
    && yum install -y rh-ruby24 rh-ruby24-ruby-devel

# Install dependent gems
RUN gem install --no-ri --no-rdoc r10k \
      json \
      puppet:5.3.3 \
      rubocop \
      puppetlabs_spec_helper \
      puppet-lint \
      onceover \
      rest-client \
      ra10ke \
    && ln -s /usr/local/bundle/bin/* /usr/local/bin/

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
    gosu nobody true;
# End CD for PE agent requirements

COPY Rakefile /Rakefile

RUN mkdir -p /repo
WORKDIR /repo
