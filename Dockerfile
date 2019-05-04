FROM debian:buster
MAINTAINER holishing
RUN groupadd --gid 9999 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 bbs \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime
USER bbs
COPY file/dreambbs_conf /tmp/dreambbs.conf
USER root
ARG RELEASE_VER=1.1.1
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
       cron \
       make \
       bmake \
       curl \
       ca-certificates \
       gcc-multilib \
       clang \
       lib32ncurses5-dev \
       gosu \
    && cd /home/ && rm -rf bbs && sh -c "curl -L https://github.com/ccns/dreambbs_snap/archive/master.tar.gz|tar -zxv" \
    && mv dreambbs_snap-$RELEASE_VER bbs && chown -R bbs:bbs /home/bbs && cd /home/bbs \
    && gosu bbs sh -c "curl -L https://github.com/ccns/dreambbs/archive/v$RELEASE_VER.tar.gz |tar -zxv" \
    && gosu bbs mv dreambbs-$RELEASE_VER dreambbs \
    && gosu bbs cp /tmp/dreambbs.conf /home/bbs/dreambbs \
    && cd /home/bbs/dreambbs && gosu bbs bmake all install clean && cd .. \
    && cd /home/bbs && ln -s bin-1.0 bin \
    && cd /home/bbs && ln -s sh-1.0 sh \
    && gosu bbs crontab /home/bbs/dreambbs/sample/crontab

# Notice, in here, bbsd started service and PROVIDE BIG5 encoding for users.
cmd ["sh","-c","gosu bbs sh /home/bbs/sh/start.sh && gosu bbs /home/bbs/bin/bbsd 8888 && /etc/init.d/cron start && while true; do sleep 10; done"]
EXPOSE 8888
