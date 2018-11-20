FROM centos:6
MAINTAINER holishing

RUN groupadd --gid 9999 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 bbs \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime
USER bbs
COPY file/dreambbs_conf /tmp/dreambbs.conf
USER root
ARG RELEASE_VER=0.96.1

# Install gosu for switch user in runtime command
# source: https://github.com/tianon/gosu/blob/master/INSTALL.md
#################################
ENV GOSU_VERSION 1.10
RUN set -ex; \
        \
        yum -y install epel-release; \
        yum -y install wget dpkg; \
        \
        dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
        wget -O /usr/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
        wget -O /tmp/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
        \
# verify the signature
        export GNUPGHOME="$(mktemp -d)"; \
        for server in $(shuf -e ha.pool.sks-keyservers.net \
            hkp://p80.pool.sks-keyservers.net:80 \
            keyserver.ubuntu.com \
            hkp://keyserver.ubuntu.com:80 \
            pgp.mit.edu) ; do \
            gpg --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
        done && \
        gpg --batch --verify /tmp/gosu.asc /usr/bin/gosu; \
        rm -r "$GNUPGHOME" /tmp/gosu.asc; \
        \
        chmod +x /usr/bin/gosu; \
# verify that the binary works
        gosu nobody true; \
        \
        yum -y remove wget dpkg; \
        yum clean all
###################################

RUN yum update -y \
    && yum install -y epel-release \
    && yum install --nogpgcheck -y \
                util-linux-ng \
                gcc \
                make \
                clang \
                glibc-devel \
                glibc-devel.i686 \
                libgcc.i686 \
                libstdc++-devel.i686 \
                ncurses-devel.i686 \
                cronie \
    && mkdir /bmake-build \
    && cd /bmake-build \
    && sh -c "curl -L http://crufty.net/ftp/pub/sjg/bmake-20171207.tar.gz | tar -zxv" \
    && cd bmake && ./boot-strap prefix=/usr/local && ./boot-strap prefix=/usr/local op=install \
    && cd / && rm -rf /bmake-build \
    && cd /home/ && rm -rf bbs && sh -c "curl -L https://github.com/ccns/dreambbs_snap/archive/v$RELEASE_VER.tar.gz|tar -zxv" \
    && mv dreambbs_snap-$RELEASE_VER bbs && chown -R bbs:bbs /home/bbs && cd /home/bbs \
    && gosu bbs sh -c "curl -L https://github.com/ccns/dreambbs/archive/v$RELEASE_VER.tar.gz |tar -zxv" \
    && gosu bbs mv dreambbs-$RELEASE_VER dreambbs \
    && gosu bbs cp /tmp/dreambbs.conf /home/bbs/dreambbs \
    && cd /home/bbs/dreambbs && gosu bbs bmake all install clean && cd .. \
    && gosu bbs crontab /home/bbs/dreambbs/sample/crontab

# Notice, in here, mbbsd started service and PROVIDE BIG5 encoding for users.
cmd ["sh","-c","gosu bbs sh /home/bbs/sh/start.sh && gosu bbs /home/bbs/bin/bbsd 8888 && service crond start && while true; do sleep 10; done"]
EXPOSE 8888
