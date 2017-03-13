FROM alpine:3.5

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV BLOG_UID=1000 BLOG_GID=1000

ADD root /

RUN set -ex \
 && apk add --no-cache \
      ansible \
      bash \
      g++ \
      openssh \
      python \
      sudo \
 && addgroup -g $BLOG_GID blog \
 && adduser -h /home/blog -D -s /bin/sh -G blog blog \
 && echo 'blog ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/blog \
 && chmod 0440 /etc/sudoers.d/blog \
 && chown -R $BLOG_UID:$BLOG_GID /home/blog

USER blog

RUN set -ex \
 && ansible-playbook -c local /home/blog/playbooks/writing_env.yml \
 && /bin/zsh -c "source /home/blog/.zshrc && antigen update"

ENTRYPOINT ["/usr/local/bin/entrypoint"]
