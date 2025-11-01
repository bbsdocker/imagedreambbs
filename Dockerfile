FROM quay.io/lib/debian:trixie-slim AS dreambbs-builder
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
		busybox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY env.compile /tmp/env.compile
COPY build_dreambbs.bash /tmp/build_dreambbs.bash
COPY dreambbs.conf /tmp/dreambbs.conf
COPY try_strl.patch /tmp/try_strl.patch

ARG SRC_REPO="https://github.com/ccns/dreambbs.git"
ARG SRC_BRANCH="master"
ARG SRC_REF="refs/heads/master"
ARG SRC_SHA

RUN sudo -iu bbs env DREAMBBS_GIT="$SRC_REPO" DREAMBBS_BRANCH="$SRC_BRANCH" DREAMBBS_SHA="$SRC_SHA" bash /tmp/build_dreambbs.bash

FROM quay.io/lib/debian:trixie-slim AS stage-fileselection
COPY --from=dreambbs-builder /home/bbs /home/bbs
COPY --from=dreambbs-builder /usr/bin/busybox /opt/busybox/sh
RUN rm -rfv /home/bbs/src
RUN ln -rsv /opt/busybox/sh /opt/busybox/sleep

FROM gcr.io/distroless/base-debian13
COPY --from=dreambbs-builder /usr/share/zoneinfo/Asia/Taipei /etc/localtime
COPY --from=dreambbs-builder /lib/x86_64-linux-gnu/libcrypt.so.1.1.0 /lib/x86_64-linux-gnu/libcrypt.so.1
COPY --from=stage-fileselection /opt/busybox /opt/busybox
COPY --from=stage-fileselection /home/bbs /home/bbs
USER 9999
WORKDIR /home/bbs
CMD ["/opt/busybox/sh","-c","/opt/busybox/sh /home/bbs/sh/start.sh && /home/bbs/bin/bbsd 8888 && while true; do /opt/busybox/sleep 10; done"]
EXPOSE 8888
