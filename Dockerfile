FROM golang:1.14.0-alpine3.11 as builder

ARG HUGO_VERSION=0.65.3
ARG RCLONE_VERSION=1.51.0

RUN set -ex \
 && apk add --no-cache \
        gcc \
        git \
        musl-dev \
 && GO111MODULE=on GO_ENABLED=0 GOOS=linux go get -a -ldflags '-extldflags "-static"' -v github.com/gohugoio/hugo@v$HUGO_VERSION \
 && GO111MODULE=on GO_ENABLED=0 GOOS=linux go get -a -ldflags '-extldflags "-static"' -v github.com/rclone/rclone@v$RCLONE_VERSION

FROM alpine:3.11

COPY --from=builder /go/bin/hugo /usr/bin/hugo
COPY --from=builder /go/bin/rclone /usr/bin/rclone

RUN set -ex \
 && apk add --no-cache \
        curl \
        git \
        make \
        npm \
 && npm install @remy/webmention
