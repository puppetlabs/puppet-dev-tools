FROM centos:centos7 as base

ARG VCS_REF
ARG GH_USER=puppetlabs

LABEL org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/${GH_USER}/puppet-dev-tools"

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

SHELL [ "/bin/bash", "-l", "-c" ]

WORKDIR /tmp

RUN yum update -y \
  && yum install -y curl gpg gcc make git wget which pkgconfig libssh2 libssh2-devel libgit2 libgit2-devel openssl epel-release \
  && yum install -y cmake3 \
  && ln -s /usr/bin/cmake3 /usr/bin/cmake

# Install RVM
RUN gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
  && curl -sSL https://get.rvm.io | bash -s stable

# Install Ruby 2.5.7
RUN rvm install 2.5.7 \
  && rvm use 2.5.7 --default

# Install PDK
RUN wget https://yum.puppet.com/puppet-tools-release-el-7.noarch.rpm \
  && rpm -ivh puppet-tools-release-el-7.noarch.rpm \
  && yum install -y pdk

# Install dependent gems
RUN mkdir /setup
WORKDIR /setup
ADD Gemfile* /setup/
RUN gem install bundler \
  && bundle config set system 'true' \
  && bundle install --jobs=3 \
  && gem install crack -v 0.4.3 \
  && rm -f /root/.bundle/config \
  && sed -i 's/Parser.new(source, opts).parse/Parser.new(source, **opts).parse/g' /usr/local/rvm/gems/ruby-2.7.1/gems/json_pure-2.1.0/lib/json/common.rb

# Cleanup
RUN yum clean all

COPY Rakefile /Rakefile

RUN mkdir /repo
WORKDIR /repo

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]

FROM base AS main
