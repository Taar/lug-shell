ARG DEBIAN_TAG=13.7-slim

FROM docker.io/library/debian:${DEBIAN_TAG} as packages

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        gdb \
        libreadline-dev \
    && rm -rf /var/lib/apt/lists/*

FROM packages as clang

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        clang \
        clang-tools \
        clang-format \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/src

VOLUME [ "/opt" ]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        clang-format \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "clang-check" ]
CMD [ "lugshell.c", "--" ]

FROM clang as clang-format

ENTRYPOINT [ "clang-format" ]
CMD [ "-i", "lugshell.c" ]

FROM packages as development

RUN mkdir -p /opt/build

WORKDIR /opt/build

VOLUME [ "/opt" ]

ENTRYPOINT [ "bash" ]

FROM packages as build

COPY ./LICENSE /opt/LICENSE
COPY ./cmake /opt/cmake
COPY ./CMakeLists.txt /opt/CMakeLists.txt
COPY ./build/build.bash /opt/build/build.bash
COPY ./docs /opt/docs
COPY ./README.md /opt/README.md
COPY ./src /opt/src

WORKDIR /opt/build

RUN ./build.bash

# This image only contains manuals (man pages)
FROM docker.io/library/debian:${DEBIAN_TAG} as manuals

# Allow man pages to be included in the image
RUN sed 's@/path-exclude /usr/share/man/*@# path-exclude /usr/share/man/*@' /etc/dpkg/dpkg.cfg.d/docker > /etc/dpkg/dpkg.cfg.d/docker

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        coreutils \
        readline-doc \
        readline-common \
        man-db \
        manpages \
        manpages-dev \
        less \
    && rm -rf /var/lib/apt/lists/*

RUN mandb

ENTRYPOINT [ "man" ]

# NOTE: the lug-shell should be the last stage defined in this file as if no target is
# provided at build time, it will be used as the default
FROM docker.io/library/debian:${DEBIAN_TAG} as lug-shell

COPY --from=build /opt/build/lug-shell /usr/bin/lug-shell
RUN mkdir -p /usr/share/doc/lug-shell

WORKDIR /usr/share/doc/lug-shell

COPY --from=build /opt/LICENSE LICENSE
COPY --from=build /opt/docs docs
COPY --from=build /opt/README.md README.md

WORKDIR /

ENTRYPOINT [ "/usr/bin/lug-shell" ]

