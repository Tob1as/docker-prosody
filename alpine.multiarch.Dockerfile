# build: docker build --no-cache --progress=plain -t docker.io/tobi312/prosody:latest -f alpine.multiarch.Dockerfile .
FROM alpine:latest

SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

ARG VCS_REF
ARG BUILD_DATE

ENV LUA_VERSION=5.4
ENV __FLUSH_LOG=yes

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
      org.opencontainers.image.title="prosody" \
      org.opencontainers.image.description="Prosody (XMPP/Jabber)" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.documentation="https://prosody.im/doc" \
      org.opencontainers.image.url="https://hub.docker.com/r/tobi312/prosody" \
      org.opencontainers.image.source="https://github.com/Tob1as/docker-prosody"

RUN set -eux; \
    apk --no-cache add \
        tzdata \
        ca-certificates \
        tini \
        runuser \
        #lua${LUA_VERSION} lua${LUA_VERSION}-socket lua${LUA_VERSION}-sec lua${LUA_VERSION}-expat lua${LUA_VERSION}-filesystem lua${LUA_VERSION}-unbound \
        prosody \
        lua${LUA_VERSION}-dbi-mysql \
        lua${LUA_VERSION}-dbi-postgresql \
        lua${LUA_VERSION}-dbi-sqlite3 \
        lua${LUA_VERSION}-ldap \
        lua${LUA_VERSION}-bitop \
        #lua${LUA_VERSION}-dev \
        luarocks${LUA_VERSION} \
        mercurial \
    ; \
    cp /etc/prosody/prosody.cfg.lua /etc/prosody/prosody.cfg.lua.backup ; \
    mkdir -p /etc/prosody/conf.d ; \
    mkdir -p /usr/lib/prosody/modules-community-available ; \
    mkdir -p /usr/lib/prosody/modules-community-enable ; \
    mkdir -p /usr/lib/prosody/modules-custom ; \
    hg clone https://hg.prosody.im/prosody-modules/ /usr/lib/prosody/modules-community-available

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN set -eux; \
    chmod +x /usr/local/bin/entrypoint.sh ; \
    sed -i -e 's/\r$//' /usr/local/bin/entrypoint.sh ; \
    mkdir /entrypoint.d

#COPY entrypoint.d/prosody.cfg.lua /etc/prosody/prosody.cfg.lua

## https://prosody.im/doc/ports (proxy, c2s, s2s, http, https, components, telnet)
EXPOSE 5000/tcp 5222/tcp 5269/tcp 5280/tcp 5281/tcp 5347/tcp 5582/tcp

# uid=100 gui=101
#USER prosody

#ENTRYPOINT ["entrypoint.sh"]
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["prosody", "-F", "--config /etc/prosody/prosody.cfg.lua"]