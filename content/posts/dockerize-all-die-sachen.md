---
title: Dockerize all die Sachen
slug: dockerize-all-die-sachen
tags:
- docker
- linux
date: "2015-07-01T13:28:00+02:00"
author: marvin
draft: false
---


Docker ist manchmal immer noch ein Buch mit sieben Siegeln für mich. In meinem Fall war die Lernnkurve nicht gerade die Beste. Aber was solls. Das meiste lernt man dann doch durch Trial and error. Ein paar kleine selbstgeschriebene Web-Apps laufen bei mir schon in Docker Containern nun wollte ich bestehende Dienste auf meinem Heimserver in Container auslagern. Vor allem die Sachen denen ich immer noch ein wenig kritisch gegenüber stehe. Da wären zum Beispiel [Owncloud](https://owncloud.org/), [Plex](http://plex.tv) und [tiny tiny rss](https://tt-rss.org). Was ich gelernt habe: Jede Anwendung fordert individuelle Entscheidungen die manchmal erst auf den zweiten Blick Sinn machen :).

## Owncloud

Meine lokale Owncloud Installation hat schon lange keine Liebe mehr gesehen. Oft benutze ich es nicht mehr und um Updates hatte ich mich auch nicht so wirklich gekümmert. Ich musste mir erstmal Gedanken was ich zum Beispiel mit PHP Anwednungen machen. Bei Python starte ich [Gunicorn](http://gunicorn.org/) im Container und richte einfach einen Reverse-Proxy (Nginx) drauf. Bei PHP brauche ich einen Layer dazwischen. Ich habe mich dafür entschieden einen minimalen Nginx mit php-fpm im Container laufen zu lassen. Davor kommt dann der Reverse Proxy mit SSL und Soße und Scharf. Und da ich php-fpm und Nginx im Container laufen haben muss, muss ich die Prozesse per [Supervisor](http://supervisord.org/) starten. Normalerweise versuche ich die einzelnen Prozesse in verschiedene Container zu packen. Hier habe ich mich explizit dagegen entschieden. Die Config dazu sieht in diesem Fall so aus:

```
[supervisord]
nodaemon = true

[program:nginx]
command = nginx
user = root
autostart = true

[program:php]
command = php5-fpm --nodaemonize
user = root
autostart = true
```

Sehr wichtig ist das Supervisor nicht als daemon läuft. Sonst schließt sich der Docker Container sofort wieder nach dem ausführen. Mein Dockerfile sieht so aus:

```
FROM nginx

RUN apt-get update && apt-get -y install bzip2 curl supervisor php5-fpm php5-gd php5-json php5-mysql php5-curl php5-intl php5-mcrypt php5-imagick php5-sqlite
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /var/log/supervisor
RUN mkdir /var/www

RUN curl -k https://download.owncloud.org/community/owncloud-8.0.4.tar.bz2 | tar jx -C /var/www/
RUN chown -Rv www-data:www-data /var/www

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY php.ini /etc/php5/fpm/
COPY nginx.conf /etc/nginx/nginx.conf

VOLUME ["/var/www/owncloud/data", "/var/www/owncloud/config"]
EXPOSE 80
CMD ["/usr/bin/supervisord"]
```

Eigentlich auch nichts wildes. Die Verzeichnisse `/var/www/owncloud/data` und `/var/www/owncloud/config` sind als Volumes deklariert. Die werde ich dann mit lokalen Verzeichnissen auf dem Host verbinden. Alle anderen Files liegen in dem passenden [Repository](https://github.com/xsteadfastx/owncloud_docker).

Grundlegend benutze ich [docker-compose](https://docs.docker.com/compose/). Es macht den Workflow für mich so viel besser. Ich schreibe in `docker-compose.yml` all meine Optionen die ich haben will (zum Beispiel die Volumes oder Ports) und mit `docker-compose up` wird alles hochgefahren. Ich muss mir mein ursprüngliches `docker run`-Kommando nicht merken. Am schönsten wird es wenn wir mehrere Container miteinander verkleben. Bei Owncloud hantieren wir mit nur einem Container. Das File sieht dann so aus:

```
owncloud:
  build: .
  ports:
    - "127.0.0.1:9998:80"
  volumes:
    - "/srv/www/owncloud/config:/var/www/owncloud/config"
    - "/srv/www/owncloud/data:/var/www/owncloud/data"
```

Wie man sieht steht nicht wirklich viel drin aber es erleichtert das starten und bauen sehr.

## tiny tiny rss

[tiny tiny rss](https://tt-rss.org) war dann meine Master-Arbeit. Hier gab es dann gleich mehrere Problemszenarien die zu bewältigen waren. Ich finge also an ein einfaches Dockerfile zusammen zu hacken. Es gab dann aber ein paar Probleme. Zum Beispiel muss die Datenbank bestehen bleiben auch wenn ich den Container lösche. Das einrichten der Datenbank erfolgt aber durch einen Setup Screen von tt-rss bei ersten aufrufen. Das gleiche gilt für das Configfile. Im Dockerfile kann man nicht andere Volumes von anderen Container definieren die zum speichern von Daten genutzt werden (dies ist ein Weg bestimmte Daten vor dem löschen zu bewahren). Also war mir klar das ich ein Script haben muss welches bei jedem erstellen des Containers sicherstellt das das tt-rss Datenbankschema in der Datenbank sich befindet und die richtige Config an der richtigen Stelle liegt. Da kommt ein Liebling von mir ins Spiel: [Ansible](http://ansible.com/). Ich definiere einen `ENTRYPOINT`. Ein einfaches Bash-Script welches Ansible aufruft und danach Supervisor um alles zu starten. Mein Ansible-Playbook sieht so aus:

```
---
- hosts: localhost
  remote_user: root

  tasks:

    - name: create ttrss config.php
      template: src=templates/config.php.j2
                dest=/var/www/tt-rss/config.php

    - name: pause everything
      pause: seconds=30

    - name: ttrss db
      mysql_db: name=ttrss
                state=present
                login_host={{ lookup('env','DB_PORT_3306_TCP_ADDR') }}
                login_user=root
                login_password={{ lookup('env','DB_ENV_MYSQL_ROOT_PASSWORD') }}
      notify: import ttrss schema

  handlers:

    - name: import ttrss schema
      mysql_db: name=ttrss
                state=import
                target=/var/www/tt-rss/schema/ttrss_schema_mysql.sql
                login_host={{ lookup('env','DB_PORT_3306_TCP_ADDR') }}
                login_user=root
                login_password={{ lookup('env','DB_ENV_MYSQL_ROOT_PASSWORD') }}
```

Ich erstelle die Config aus einem Template. Dann kommt der "hacky" Teil. Ich muss 30 Sekunden warten. Dies beruht darauf das `docker-compose` alle Container parallel startet und dadruch bekomme ich Connection Probleme bei einrichten der Datenbank weil diese einfach noch nicht hochgefahren ist. Nicht schön... läuft aber. Dann gehen wir sicher das es eine DB mit dem Namen "ttrss" gibt. Wenn nicht wird der Handler `import ttrss schema` angestoßen der dann das Schema importiert. Die Supervisor-Config sieht so aus:

```
[supervisord]
nodaemon = true

[program:nginx]
command = nginx
user = root
autostart = true

[program:php]
command = php5-fpm --nodaemonize
user = root
autostart = true

[program:ttrss-update-daemon]
command = php /var/www/tt-rss/update_daemon2.php
user = www-data
autostart=true
```

Was dazu kam ist der `ttrss-update-daemon`. Er wird gestartet um die Feeds, im Hintergrund, zu aktualisieren. Die `docker-compose.yml` sieht wie folgt aus:

```
ttrss:
  build: .
  ports:
    - "127.0.0.1:9997:80"
  environment:
    - URL_PATH=https://reader.domain.foo
  links:
    - db
db:
  image: mariadb
  volumes_from:
    - ttrss-data
  environment:
    - MYSQL_ROOT_PASSWORD=mysecretpassword

```

Hier sieht mand ie ganze docker-compose Magic. Wir definieren alle Container die gebraucht werden und vor allem wie sie verlinkt werden sollen. Dann können wir auch gleich noch ein paar Variabeln mitgeben. `URL_PATH` wird für die tt-rss Config gebraucht und `MYSQL_ROOT_PASSWORD` um MariaDB zu initialisieren. Wir benutzen einen [Data-Only-Container](https://docs.docker.com/userguide/dockervolumes/) um die Datenbank zu speichern. Diesen legen wir mit `docker run --name ttrss-data mariadb true` an. Wir benutzen hier das `mariadb`-Image damit die Permissions mit dem Server übereinstimmen. `docker-compose up` und den Reverse Proxy setzen. Zack fertig! [Hier](https://github.com/xsteadfastx/ttrss_docker) gibt es alle benötigten Files.

## Plex Media Server

Ich liebe Plex ja. Auch wenn es teilweise closed-source ist komme ich einfach nicht davon weg. Von der Usability habe ich bis jetzt nicht vergleichbares gefunden. Also was liegt näher als Plex auch im Container laufen zu lassen. Komischerweise war Plex die einfachste Aufgabe bis jetzt. Alles ziemlich straight-forward. Deswegen einfach [hier](https://github.com/xsteadfastx/plex_docker) alle Files. Bis jetzt rennt Plex. Na mal schauen :)

## Links

Hier sind die Links zu meinen Dockerfiles und den dazugehörigen Helper.

* [owncloud_docker](https://github.com/xsteadfastx/owncloud_docker)
* [ttrss_docker](https://github.com/xsteadfastx/ttrss_docker)
* [plex_docker](https://github.com/xsteadfastx/plex_docker)