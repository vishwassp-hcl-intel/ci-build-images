#
# Copyright (c) 2019
# Intel
#
# SPDX-License-Identifier: Apache-2.0
#
FROM alpine:3.9 as build

LABEL license='SPDX-License-Identifier: Apache-2.0' \
      copyright='Copyright (c) 2019: Intel'

RUN apk add --no-cache \
    autoconf \
    automake \
    file \
    gcc \
    git \
    libtool \
    make \
    musl-dev \
    valgrind

WORKDIR /usr/local/src

ARG JQ_TAG=jq-1.6

RUN git clone --branch ${JQ_TAG} --quiet --recurse-submodules https://github.com/stedolan/jq
RUN git config --global submodule.modules/oniguruma.ignore dirty

WORKDIR /usr/local/src/jq

RUN ./configure --help &>/dev/null || autoreconf -fi
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-docs \
    --disable-dependency-tracking \
    --disable-maintainer-mode \
    --disable-shared \
    --enable-all-static
RUN make -j4 LD_FLAGS=-all-static
# RUN make -j4 check
RUN make -j4 prefix=/opt/local install

FROM scratch
COPY --from=build /opt/local/bin/   /opt/local/bin/
COPY --from=build /opt/local/share/ /opt/local/share/
ENV PATH /opt/local/bin
ENTRYPOINT ["jq"]
CMD ["--help"]
