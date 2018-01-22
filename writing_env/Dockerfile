FROM alpine:edge

ENV LANG C.UTF-8
ENV SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt

ENV BLOG_UID 1000
ENV BLOG_GID 1000

# prepare repositories
RUN set -ex \
 && echo "http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
 && apk update

# add files
ADD root /

# prepare for provisioning
RUN set -ex \
 && apk upgrade -a --no-cache \
 && apk add --no-cache\
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
 && touch ~/.profile \
 && ansible-playbook -i ~/.batcave/hosts ~/.batcave/shell.yml -c local --extra-vars="host=127.0.0.1" \
 && ansible-playbook -c local /home/blog/playbooks/writing_env.yml

EXPOSE 8000
