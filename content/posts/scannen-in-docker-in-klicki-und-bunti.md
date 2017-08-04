Title: Scannen in Docker, in klicki und bunti
Date: 2017-08-04 11:45
Slug: scannen-in-docker-in-klicki-und-bunti
Tags: docker, photography, vuescan

Schon seit der Entdeckung der analogen Fotografie für mich, entwickel ich die schwarz-weiß Negative selber und scanne sie dann mit meinem Epson 4490. Den hatte ich mir damals gekauft, da er einerseits bei Media-Markt verfügbar bar und auch 120er Rollfilm scannen konnte. Zu der Zeit entdeckte ich meine Liebe für die [Holga Kamera](https://www.flickr.com/photos/marvinxsteadfast/albums/72157613283952566). Die Halter für die Filme sind eher ein wenig wackelig und ich hatte am Anfang Probleme das das Negativ das Glas des Scanner berührte und es zu [Newton Ringen](https://de.wikipedia.org/wiki/Newtonsche_Ringe) kam. Alles nicht so professionell aber machbar. Zu der Zeit nutze ich einen Mac Mini und war froh das es die Epson Software auch für diesen gab. Später war ich wieder zurück auf Linux und nutze Virtualbox und ein altes Windows XP um die Epson Windows Software zum laufen zu bringen. Letztes Jahr, nach dem Umzug, war mein Setup noch nicht ganz aufgebaut und ich musste ein paar Negative scannen. Ich kaufte mir [VueScan](https://www.hamrick.com/). Dies soll sowas wie der heilige Gral des Scannens sein. Die Software ist unter anderem von einem NASA Mitarbeiter programmiert und kommt mit vielen Treibern. Gerade wenn es für aktuelle Betriebssysteme keine mehr gibt, ein Segen. In meinem Fall, Epson 4490 mit VueScan unter Linux, musste ich noch einen Epson Treiber installieren. Ich weiß nicht wie ihr das seht, aber mir dreht sich alles um wenn ich als `root` eine `install.sh` ausführen soll die irgendwelchen Kram in mein System kopiert, welches ich im schlechtesten Fall per Hand wieder rauspopeln muss. Sowas wollte ich nicht mehr. Docker und X11 hatte ich bis jetzt nicht wirklich benutzt, sah darin aber den perfekten Usecase.

```
FROM ubuntu:xenial

ENV GOSU_VERSION 1.10

RUN set -ex \
 && apt-get update \
 && apt-get install -y \
        ca-certificates \
        wget \
 && cd /tmp \
 && wget https://download2.ebz.epson.net/iscan/plugin/gt-x750/deb/x64/iscan-gt-x750-bundle-1.0.0.x64.deb.tar.gz \
 && tar xvfz iscan-gt-x750-bundle-1.0.0.x64.deb.tar.gz \
 && iscan-gt-x750-bundle-1.0.0.x64.deb/install.sh \
 && wget https://www.hamrick.com/files/vuex6495.tgz \
 && tar xvfz vuex6495.tgz \
 && cp VueScan/* /usr/local/bin/ \
 && rm -rf /tmp/* \
 && rm -rf /var/lib/apt/lists/* \
 && cd /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["vuescan"]
```

Dieses Dockerfile macht nichts anderes als die Treiber von Epson herunter zu laden und zu installieren. Das gleiche gilt für VueScan. Ich habe mich aus Feigheit für ein Ubuntu Docker Image entschieden. Dies ist am nächsten zum den System auf dem ich es laufen lassen will.

```shell
#!/bin/sh

set -e

if [ "$1" = "vuescan" ];then

        echo "---> starting vuescan"
        vuescan

        echo "---> fix permissions"
        chown -R $USERID:$GROUPID /root/Scan
        chown -R $USERID:$GROUPID /root/.vuescan
        chown $USERID:$GROUPID /root/.vuescanrc
        exit

fi

exec "$@"
```
Hier komme ich schon zu dem einen Problem was ich hatte. Es war mir nicht möglich den USB Scanner mit einem anderen Benutzer im Container zu benutzen. Vielleicht finde ich ja nicht einen richtigen Hinweis. So trickse ich weiter rum und fixe die lokalen Permissions wenn ich VueScan beende.

Ich lege mir immer gerne Makefiles an. So muss ich nicht erstmal schauen wie ich die Sachen richtig schreibe oder mit welchen wilden Optionen ich den Container starte.

```
PHONY.: build run

USERID=$(shell id -u)
GROUPID=$(shell id -g)

build:
	docker build -t vuescan .

run:
	xhost +local:
	touch /home/$(USER)/.vuescanrc
	docker run --rm -ti --privileged -e USERID=$(USERID) -e GROUPID=$(GROUPID) -e DISPLAY=$(DISPLAY) -e XAUTHORITY=$(HOME)/.Xauthority -v /tmp/.X11-unix:/tmp/.X11-unix -v /home/$(USER)/Nextcloud/Scan:/root/Scan -v /home/$(USER)/.vuescan:/root/.vuescan -v /home/$(USER)/.vuescanrc:/root/.vuescanrc -v /dev/bus/usb:/dev/bus/usb vuescan

```

Ich übergebe dem Container die User-ID und Gruppen-ID damit ich Permissions fixen kann. Dazu kommt `--privileged`. Dies ist nötig um direkten Zugriff auf den USB-Bus des Host Systems zu haben. `-e DISPLAY=$(DISPLAY)`, `-e XAUTHORITY=$(HOME)/.Xauthority` und `-v /tmp/.X11-unix:/tmp/.X11-unix` sind nötig um auf den Xserver zu zugreifen. Wichtig dafür auch das `xhost +local:` im Makefile. Alle anderen Volumes sind VueScan config-Verzeichnisse und das super wichtige `/dev/bus/usb`, der direkte Zugriff auf den USB-Bus.

Ein wenig gefrickel... aber am Ende ging es.
