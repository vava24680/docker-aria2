# Build stage
FROM alpine:3.10 AS build-base

WORKDIR /aria2

RUN set -x && \
    apk update && \
    apk add --no-cache -t .aria2 \
        build-base \
        cppunit-dev \
        openssl-dev \
        libssh2-dev \
        libssh2-static \
        c-ares-dev \
        zlib-dev \
        sqlite-dev \
        sqlite-static \
        pkgconf && \
    wget https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0.tar.gz && \
    tar -zxf aria2-1.35.0.tar.gz && \
    cd aria2-1.35.0 && \
    ./configure ARIA2_STATIC=yes --without-gnutls --with-openssl \
                --disable-bittorrent --disable-metalink && \
    make && \
    make install && \
    make clean && \
    apk del .aria2

# Final stage
FROM alpine:3.10

WORKDIR /aria2

COPY --from=build-base /usr/local/bin/aria2c /usr/local/bin/

COPY ./aria2/ .

RUN apk update && \
    apk add --no-cache coreutils

CMD ["./entrypoint.sh"]
