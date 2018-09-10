FROM centos:7

RUN yum makecache&& yum install -y ruby ruby-dev build-essentials && \
    rpm -i https://pm.puppet.com/cgi-bin/pdk_download.cgi?arch=x86_64\&dist=el\&rel=7\&ver=latest
