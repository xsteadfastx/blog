FROM python:3.7.3-alpine3.9 as base
ENV LANG C.UTF-8
ENV SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt
ENV BLOG_UID 1000
ENV BLOG_GID 1000
RUN set -ex \
 && apk upgrade -a --no-cache \
 && pip install -U pip \
 && mkdir /wheels
COPY requirements.txt /wheels/requirements.txt

FROM base as wheel_builder
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
 && pip wheel -w /wheels -r /wheels/requirements.txt

FROM base
COPY --from=wheel_builder /wheels /wheels
RUN set -ex \
 && pip install -r /wheels/requirements.txt -f /wheels \
 && rm -rf /root/.cache \
 && rm -rf /wheels \
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
USER blog
WORKDIR /blog
EXPOSE 8000
