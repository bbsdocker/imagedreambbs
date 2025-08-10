ARG DEBIAN_VERSION
FROM docker.io/library/debian:${DEBIAN_VERSION}-slim AS dreambbs-builder
RUN groupadd --gid 9999 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 --no-create-home bbs \
    && mkdir -pv /home/bbs \
    && chown -R bbs:bbs /home/bbs \
    && rm /etc/localtime \
    && ln -rsv /usr/share/zoneinfo/Asia/Taipei /etc/localtime

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

FROM docker.io/library/debian:${DEBIAN_VERSION}-slim AS stage-fileselection
COPY --from=dreambbs-builder /home/bbs /home/bbs
RUN rm -rfv /home/bbs/src

FROM docker.io/library/debian:${DEBIAN_VERSION}-slim
COPY --from=stage-fileselection /home/bbs /home/bbs
RUN groupadd --gid 9999 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 --no-create-home bbs \
    && mkdir -pv /home/bbs \
    && chown -R bbs:bbs /home/bbs \
    && rm /etc/localtime \
    && ln -rsv /usr/share/zoneinfo/Asia/Taipei /etc/localtime
USER bbs
WORKDIR /home/bbs
cmd ["sh","-c","sh /home/bbs/sh/start.sh && /home/bbs/bin/bbsd 8888 && while true; do sleep 10; done"]
EXPOSE 8888
