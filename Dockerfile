FROM quay.io/centos/centos:stream8
MAINTAINER "Sean Ho <holishing@ccns.ncku.edu.tw>"
RUN groupadd --gid 9999 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 --no-create-home bbs \
    && mkdir /home/bbs \
    && chown bbs:bbs /home/bbs \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime
COPY file/dreambbs_conf /tmp/dreambbs.conf
COPY build_dreambbs.bash /tmp/build_dreambbs.bash
ENV DREAMBBS_GIT=$DREAMBBS_GIT
ENV DREAMBBS_SNAP_GIT=$DREAMBBS_SNAP_GIT

RUN yum update -y \
    && yum install -y epel-release \
    && yum install --nogpgcheck -y \
                util-linux-ng \
                gcc-toolset-10 \
                make \
                cmake \
                glibc-devel \
                glibc-devel.i686 \
                libgcc.i686 \
                libstdc++-devel.i686 \
                ncurses-devel.i686 \
                cronie \
                git \
                sudo \
    && echo 'source scl_source enable gcc-toolset-10' >> /etc/profile.d/enablegcc10.sh \
    && sudo -iu bbs sh /tmp/build_dreambbs.bash

cmd ["sh","-c","sudo -iu bbs sh /home/bbs/sh/start.sh && sudo -iu bbs /home/bbs/bin/bbsd 8888 && /etc/init.d/cron start && while true; do sleep 10; done"]
EXPOSE 8888
