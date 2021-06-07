FROM quay.io/centos/centos:stream8
MAINTAINER "Sean Ho <holishing@ccns.ncku.edu.tw>"
RUN groupadd --gid 9999 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 --no-create-home bbs \
    && mkdir /home/bbs \
    && chown bbs:bbs /home/bbs \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime

RUN rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official \
    && yum update -y \
    && yum install -y epel-release \
    && rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 \
    && yum update -y \
    && yum install -y \
                util-linux-ng \
                gcc-toolset-10-gcc \
                gcc-toolset-10-gcc-c++ \
                gcc-toolset-10-make \
                cmake \
                glibc-devel \
                ncurses-devel \
                git \
                sudo \
    && echo 'source scl_source enable gcc-toolset-10' >> /etc/profile.d/enablegcc10.sh

COPY env.compile /tmp/env.compile
COPY build_dreambbs.bash /tmp/build_dreambbs.bash
COPY dreambbs.conf /tmp/dreambbs.conf

ARG SRC_REPO="https://github.com/ccns/dreambbs.git"
ARG SRC_BRANCH="master"
ARG SRC_REF="refs/heads/master"
ARG SRC_SHA

RUN sudo -iu bbs env DREAMBBS_GIT="$SRC_REPO" DREAMBBS_BRANCH="$SRC_BRANCH" DREAMBBS_SHA="$SRC_SHA" sh /tmp/build_dreambbs.bash

cmd ["sh","-c","sudo -iu bbs sh /home/bbs/sh/start.sh && sudo -iu bbs /home/bbs/bin/bbsd 8888 && while true; do sleep 10; done"]
EXPOSE 8888
