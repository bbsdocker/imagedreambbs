FROM debian:buster
MAINTAINER holishing
RUN groupadd --gid 9999 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 bbs \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime
USER bbs
COPY file/dreambbs_conf /tmp/dreambbs.conf
USER root
ARG SNAPVER=2931fc7b80c690381cad767413d678e2f4aefaf1
ARG  GITVER=5fa7e82b0dfb64230daf0ad0ee484eb5847b5a3f
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
