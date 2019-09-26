#
# Copyright (c) 2019
# Intel
#
# SPDX-License-Identifier: Apache-2.0
#
FROM ernestoojeda/rpi-ubuntu:arm64

LABEL license='SPDX-License-Identifier: Apache-2.0' \
  copyright='Copyright (c) 2019: Intel'

RUN apt-get update && apt-get install -y curl

# This layer contains all the components build from src like openssl, openresty, kong, etc
# We are pre-caching these components because they take over 5 hours to build
COPY --from=nexus3.edgexfoundry.org:10003/kong-arm-parent:15b8bf69735138dc7e6d4f1900f12f3b4229e33a /usr/local /usr/local

RUN addgroup --gid 1337 kong \
  && adduser --system --uid 1337 --gid 1337 --disabled-password --no-create-home kong \
  && chown -R kong:0 /usr/local/kong \
  && chmod -R g=u /usr/local/kong

RUN  set -ex; \
  \
  curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c; \
  \
  fetch_deps='gcc libc-dev'; \
  apt-get update; \
  apt-get install -y --no-install-recommends $fetch_deps; \
  rm -rf /var/lib/apt/lists/*; \
  gcc -Wall \
  /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
  chown root:root /usr/local/bin/su-exec; \
  chmod 0755 /usr/local/bin/su-exec; \
  rm /usr/local/bin/su-exec.c; \
  \
  apt-get purge -y --auto-remove $fetch_deps

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["kong", "docker-start"]

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/openresty/bin:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin