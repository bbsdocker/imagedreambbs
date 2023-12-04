FROM docker.io/library/debian:bookworm-slim
MAINTAINER "Sean Ho <holishing@ccns.ncku.edu.tw>"
RUN groupadd --gid 9999 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 --no-create-home bbs \
    && mkdir /home/bbs \
    && chown bbs:bbs /home/bbs \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
		gcc \
		g++ \
		make \
		binutils \
		cmake \
		libncurses-dev \
		git \
		sudo \
		locales \
		locales-all \
		build-essential \
		ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY env.compile /tmp/env.compile
COPY build_dreambbs.bash /tmp/build_dreambbs.bash
COPY dreambbs.conf /tmp/dreambbs.conf

ARG SRC_REPO="https://github.com/ccns/dreambbs.git"
ARG SRC_BRANCH="master"
ARG SRC_REF="refs/heads/master"
ARG SRC_SHA

RUN sudo -iu bbs env DREAMBBS_GIT="$SRC_REPO" DREAMBBS_BRANCH="$SRC_BRANCH" DREAMBBS_SHA="$SRC_SHA" bash /tmp/build_dreambbs.bash

cmd ["sh","-c","sudo -iu bbs sh /home/bbs/sh/start.sh && sudo -iu bbs /home/bbs/bin/bbsd 8888 && while true; do sleep 10; done"]
EXPOSE 8888
