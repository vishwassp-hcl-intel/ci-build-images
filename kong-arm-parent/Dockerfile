#
# Copyright (c) 2019
# Intel
#
# SPDX-License-Identifier: Apache-2.0
#
FROM hypriot/rpi-alpine

LABEL license='SPDX-License-Identifier: Apache-2.0' \
  copyright='Copyright (c) 2019: Intel'

LABEL maintainer="Ernesto Ojeda <ernesto.ojeda@intel.com>, Sven Walther <sven@walther.world>"

ENV OPENSSL_VERSION 1.0.2h
ENV OPENRESTY_VERSION 1.13.6.1
ENV KONG_VERSION 1.0.3
ENV PCRE_VERSION=8.40
ENV LUAROCKS_VERSION=2.4.3

RUN apk add --update alpine-sdk

RUN apk add --no-cache --virtual .build-deps wget tar ca-certificates \
  && apk add --no-cache libgcc openssl pcre perl tzdata curl libcap su-exec unzip zlib-dev 

RUN wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz \
  && tar -xvf pcre-${PCRE_VERSION}.tar.gz

RUN wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
  && tar -zvxf openssl-${OPENSSL_VERSION}.tar.gz \
  && wget https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-${OPENSSL_VERSION}-sess_set_get_cb_yield.patch \
  && cd openssl-${OPENSSL_VERSION}/ \
  && patch -p1 < ../openssl-${OPENSSL_VERSION}-sess_set_get_cb_yield.patch \
  && ./config -fPIC \
  && make -j4 \
  && make install \
  && cd ..

RUN	wget -O kong.tar.gz "https://bintray.com/kong/kong-community-edition-alpine-tar/download_file?file_path=kong-community-edition-${KONG_VERSION}.apk.tar.gz" \
  && wget -O openresty.tar.gz https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz \
  && wget https://github.com/Kong/openresty-patches/archive/master.tar.gz 


RUN	tar -xzf /openresty.tar.gz \
  && tar zxvf master.tar.gz \
  && cd openresty-${OPENRESTY_VERSION} \
  && cd bundle \
  && for i in ../../openresty-patches-master/patches/${OPENRESTY_VERSION}/*.patch; do patch -p1 < $i; done \
  && cd .. \
  && ./configure --with-pcre=../pcre-${PCRE_VERSION} --with-openssl=../openssl-${OPENSSL_VERSION} -j2 --with-pcre-jit  --with-http_ssl_module --with-http_realip_module   --with-http_stub_status_module  --with-http_v2_module \
  && make -j4 \
  && sudo make install \
  && export PATH="$PATH:/usr/local/openresty/bin"


RUN wget -O luarocks.tar.gz http://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz \
  && tar -xzf luarocks.tar.gz \
  && cd luarocks-${LUAROCKS_VERSION} \
  && ./configure --lua-suffix=jit --with-lua=/usr/local/openresty/luajit --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1  \
  && make -j4 build \
  && make install \
  && cd ..

RUN apk add --no-cache bsd-compat-headers m4

RUN luarocks install kong ${KONG_VERSION}-0 OPENSSL_DIR=/usr/local/ssl CRYPTO_DIR=/usr/local/ssl

RUN cd /tmp \
  && tar xvf /kong.tar.gz \
  && cp /tmp/usr/local/bin/kong /usr/local/openresty/bin \
  && ln -s /usr/local/openresty/bin/kong /usr/local/bin/kong \
  && cp -a /tmp/usr/local/kong /usr/local

RUN kong roar