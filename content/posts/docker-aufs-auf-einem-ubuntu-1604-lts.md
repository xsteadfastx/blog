---
title: Docker aufs auf einem Ubuntu 16.04 LTS
slug: docker-aufs-auf-einem-ubuntu-1604-lts
tags:
- ubuntu
- docker
- linux
- mastodon
date: "2017-05-31T13:58:00+02:00"
author: marvin
draft: false
---
Ich bin gestern auf was gestossen. Ich betreibe einen kleinen Server mit einer [Mastodon](https://mastodon.social/about) Instanz mit nur mir als User. Der Server auf dem dies läuft ist ein Ubuntu 16.04 LTS.

Das neue Mastodon Docker Image hat einen Entrypoint der bei jedem Aufruf des Containers erstmal einen Haufen Files nach ihren Benutzerrechten abfragt und diese dann gegebenenfalls ändert. Dies hat beim letzten Update dann einfach Stunden gedauert, da bei jeder Datenbank-Migration oder Assert-Kompilierung erstmal wieder alle Files durchkämmt wurden. Ein Graus. Ein wenig in den Bugreports von Mastodon geschaut und auch [was](https://github.com/tootsuite/mastodon/issues/3194) gefunden. Anscheinend liegt das an dem Storagedriver `overlay2` und mit `aufs` sollte dies "viel schneller" gehen. Unter Ubuntu Zesty ist `aufs` wohl auch der Default. Nun unter 16.04 sieht man davon nichts. Dies kann man mit `grep aufs /proc/filesystems` überprüfen. Es gibt aber einen Weg...

1. Mit `sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual` die passenden Pakete installieren

2. Mit `sudo modprobe aufs` das Kernelmodul laden

3. `grep aufs /proc/filesystems` sollte nun was auswerfen

4. Das File `/etc/docker/daemon.conf` so anpassen das auch wirklich `aufs` genutzt wird

        {
            "storage-driver": "aufs"
        }

5. Docker neu starten mit `service docker restart`

6. Mit `docker info` überprüfen ob wirklich `aufs` genutzt wird 

7. `aufs` zu `/etc/modules` hinzufügen damit es auch nach einem Neustart funktioniert

8. Nun kann `/var/lib/docker/overlay2` gelöscht werden. Alle Images müssen nun neu heruntergeladen oder gebaut werden