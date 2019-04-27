FROM i386/debian:buster
MAINTAINER holishing
RUN groupadd --gid 9999 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 bbs \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime
USER bbs
COPY file/dreambbs_conf /tmp/dreambbs.conf
USER root
ARG SNAPVER=0c7be91bf3b7b6b19c03f2212769825a32c6aa32
ARG  GITVER=556895cb50072dae1ceff201a11def52b54b2ef7
RUN apt update \
    && apt upgrade -y \
    && apt-get install -y --no-install-recommends \
       cron \
       make \
       bmake \
       curl \
       ca-certificates \
       clang \
       libncurses5-dev \
       gosu \
    && cd /home/ && rm -rf bbs && sh -c "curl -L https://github.com/ccns/dreambbs_snap/archive/$SNAPVER.tar.gz|tar -zxv" \
    && mv dreambbs_snap-$SNAPVER bbs && chown -R bbs:bbs /home/bbs && cd /home/bbs \
    && gosu bbs sh -c "curl -L https://github.com/ccns/dreambbs/archive/$GITVER.tar.gz|tar -zxv" \
    && gosu bbs mv dreambbs-$GITVER dreambbs \
    && gosu bbs cp /tmp/dreambbs.conf /home/bbs/dreambbs \
    && cd /home/bbs/dreambbs && gosu bbs bmake all install clean && cd .. \
    && gosu bbs crontab /home/bbs/dreambbs/sample/crontab \
    && rm -rf /home/bbs/dreambbs
# Notice, in here, mbbsd started service and PROVIDE BIG5 encoding for users.
cmd ["sh","-c","gosu bbs sh /home/bbs/sh/start.sh && gosu bbs /home/bbs/bin/bbsd 8888 && /etc/init.d/cron start && while true; do sleep 10; done"]
EXPOSE 8888
