FROM alpine:3.4

ENV SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt

RUN apk add --update \
      bash \
      openssh \
      python \
      sudo \
 && rm -rf /var/cache/apk/*

# create ssh keys
RUN ssh-keygen -A

# add vagrant user
RUN adduser -h /home/vagrant -s /bin/sh -D vagrant

# configure SSH access
RUN mkdir -p /home/vagrant/.ssh \
 && echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys \
 && chown -R vagrant: /home/vagrant/.ssh \
 && echo -n 'vagrant:vagrant' | chpasswd

# enable passwordless sudo for the "vagrant" user
RUN echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant \
 && chmod 0440 /etc/sudoers.d/vagrant

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-o", "UseDNS=no", "-o", "UsePAM=no"]
