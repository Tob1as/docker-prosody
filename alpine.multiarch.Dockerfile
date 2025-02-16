FROM alpine:latest

SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

ARG VCS_REF
ARG BUILD_DATE

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
      org.opencontainers.image.title="prosody" \
      org.opencontainers.image.description="Prosody (XMPP/Jabber)" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.url="https://hub.docker.com/r/tobi312/prosody" \
      org.opencontainers.image.source="https://github.com/Tob1as/docker-prosody"

RUN set -eux; \
    apk --no-cache add \
    #git wget curl nano zip unzip \
    tzdata \
    libidn \
    icu-libs \
    libssl3 \
    libevent-dev \
    libpq-dev \
    sqlite-dev \
    lua5.2-bitop \
    lua5.2-dbi-mysql \
    lua5.2-dbi-postgresql \
    lua5.2-dbi-sqlite3 \
    lua5.2-cqueues \
    lua5.2-expat \
    lua5.2-filesystem \
    lua5.2-sec \
    lua5.2-socket \
    lua5.2-lzlib \
    lua5.2-ldap \
    lua5.2 \
    luarocks5.2 \
    openssl \
    ca-certificates \
    prosody \
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

## https://prosody.im/doc/ports (proxy, c2s, s2s, http, https, components)
EXPOSE 5000 5222 5269 5280 5281 5347

VOLUME ["/etc/prosody/", "/etc/prosody/conf.d/", "/usr/lib/prosody/modules-custom"]

USER prosody

ENTRYPOINT ["entrypoint.sh"]
CMD ["prosody"]
