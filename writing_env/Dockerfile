FROM alpine:3.6

ENV LANG C.UTF-8
ENV SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt

ENV BLOG_UID 1000
ENV BLOG_GID 1000

ENV PANDOC_VERSION 1.19.2.1

# prepare repositories
RUN set -ex \
 && echo "http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
 && apk update

# install pandoc
RUN set -ex \
 && apk add --virtual .buildDeps \
        ghc \
        cabal \
        linux-headers \
        musl-dev \
        zlib-dev \
        curl \
 && mkdir /tmp/pandoc \
 && cd /tmp/pandoc \
 && curl -fsSL "https://hackage.haskell.org/package/pandoc-$PANDOC_VERSION/pandoc-$PANDOC_VERSION.tar.gz" | tar -xzf - \
 && cd "/tmp/pandoc/pandoc-$PANDOC_VERSION" \
 && cabal update \
 && cabal install --only-dependencies \
 && cabal configure --prefix=/usr/local \
 && cabal build \
 && cabal copy \
 && cd / \
 && rm -rf /tmp/pandoc \
 && rm -rf /root/.cabal \
 && rm -rf /root/.ghc \
 && apk del .buildDeps

# add files
ADD root /

# prepare for provisioning
RUN set -ex \
 && apk add \
      ansible \
      bash \
      ca-certificates \
      g++ \
      git \
      openssh \
      python \
      sudo \
 && addgroup -g $BLOG_GID blog \
 && adduser -h /home/blog -D -s /bin/sh -G blog blog \
 && echo 'blog ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/blog \
 && chmod 0440 /etc/sudoers.d/blog \
 && chown -R $BLOG_UID:$BLOG_GID /home/blog

# switch user to blog
USER blog

# provision
RUN set -ex \
 && git clone https://github.com/xsteadfastx/batcave.git ~/.batcave \
 && ansible-playbook -i ~/.batcave/hosts ~/.batcave/shell.yml -c local --extra-vars="hosts=127.0.0.1" \
 && ansible-playbook -c local /home/blog/playbooks/writing_env.yml \
 && /bin/zsh -c "source /home/blog/.zshrc && antigen update"

# clean up
RUN set -ex \
 && sudo rm -rf /var/cache/apk/*

EXPOSE 8000
