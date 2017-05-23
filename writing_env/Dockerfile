FROM alpine:3.5

ENV LANG C.UTF-8
ENV SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt
ENV BLOG_UID 1000
ENV BLOG_GID 1000

ADD root /

RUN set -ex \
 && apk add --update \
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

USER blog

RUN set -ex \
 && git clone https://github.com/xsteadfastx/batcave.git ~/.batcave \
 && ansible-playbook -i ~/.batcave/hosts ~/.batcave/shell.yml -c local --extra-vars="hosts=127.0.0.1" \
 && ansible-playbook -c local /home/blog/playbooks/writing_env.yml \
 && /bin/zsh -c "source /home/blog/.zshrc && antigen update" \
 && sudo rm -rf /var/cache/apk/*

EXPOSE 8000
