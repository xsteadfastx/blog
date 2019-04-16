FROM python:3.7.3-alpine3.9 as base
ENV LANG C.UTF-8
ENV SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt
ENV BLOG_UID 1000
ENV BLOG_GID 1000
RUN set -ex \
 && echo "http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
 && apk upgrade -a --no-cache \
 && apk add --no-cache \
        lftp \
        make \
        tzdata \
 && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
 && echo "Europe/Berlin" >  /etc/timezone \
 && apk del tzdata \
 && addgroup -g $BLOG_GID blog \
 && adduser -h /home/blog -D -s /bin/sh -G blog blog \
 && chown -R $BLOG_UID:$BLOG_GID /home/blog
COPY requirements.txt .

FROM base as builder
RUN set -ex \
 && apk add --no-cache\
        ca-certificates \
        g++ \
        git \
        ca-certificates \
        cython \
        gcc \
        git \
        linux-headers \
        make \
        musl-dev \
 && pip install -r requirements.txt

FROM base
COPY --from=builder /root/.cache /root/.cache
RUN set -ex \
 && pip install -r requirements.txt \
 && rm -rf /root/.cache \
 && rm requirements.txt
USER blog
WORKDIR /blog
EXPOSE 8000
