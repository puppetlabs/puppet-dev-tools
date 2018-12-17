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
RUN gem install --no-ri --no-rdoc puppet:5.3.3 \
      r10k \
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
