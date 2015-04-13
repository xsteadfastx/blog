Title: MySQL Server mit Docker
Slug: mysql-server-mit-docker
Date: 2015-02-05 08:50
Tags: docker, mysql

Es ist schon ein Jahr her das ich mir mal [Docker](http://docker.com) angeschaut habe. Bis dato war meine einzige Erfahrung mit "Virtualisierung" VMware im Desktopeinsatz und Virtualbox wenn ich mal eine Windows-Umgebung unter Linux brauche. Nun gibt es diesen Hype um Docker. Vereinfacht gesagt geht es darum einzellne Anwendungen in seperaten Linux-Container laufen zu lassen. Zum Beispiel kann man als Entwickler seine schöne Webapp komplett zusammen kleben, den Container exportieren und dem Admin zum ausrollen geben. Desweitern ist es auch möglich mehrere Container zusammen zu kleben. Zum Beispiel wenn die App in ihrem eignen Container noch eine Datenbank braucht.

Ich wollte es mal ausprobieren. Und zwar einen einfachen MySQL-Server in einem Docker Container laufen lassen. Problem ist nur: Hat man sein Container fertig und darin entstehen Veränderungen, zum Beispiel in dem Sachen in die Datenbank geschrieben werden, müssten diese Änderungen explizit wieder "committed" werden um sie auch nach einem Neustart zu erhalten. Nun gibt es einen anderen Ansatz für dieses Problem. Es gibt unter Docker [Volumes](https://docs.docker.com/userguide/dockervolumes/). Diese wollen genau das umgehen. Man definiert Verzeichnisse im Docker-Container die erhalten bleiben sollen. Funktioniert auch ganz fein nur sollte man diese Volumes in einem seperaten Container anlegen und den MySQL-Container anweisen die Volumes aus dem DATA-Container zu benutzen. Dies spielt der Modularität Dockers völlig in die Karten. Docker hat mein Gehirn ziemlich zermatscht, aber im Endeffekt hat es geklappt.

Erstmal habe ich Daten-Container mit dem Namen `mysql-data` angelegt:

	docker run --name mysql-data -v /var/lib/mysql -v /var/log/mysql 32bit/ubuntu:14.04 true

Der macht nicht viel. Er definiert die Verzeichnisse `/var/lib/mysql` und `/var/log/mysql` als Volumes, startet ein ubuntu Image und führ den Befehl `true` aus. Mit `docker ps -a` kann man sich alle Container anschauen:

	706e6f2ddc21        32bit/ubuntu:14.04   "true"                 10 days ago         Exited (0) 10 days ago                            mysql-data

Dieser muss garnicht laufen. Er definiert quasi nur die Volumes für uns. Nun habe ich mich an den MySQL-Container gemacht. Dafür habe ich von einem Ubuntu-Image eine Bash-Shell gestartet. Wichtig dabei die Angabe die `volumes` von unserem Container mit dem Namen `mysql-data` zu verwenden. Das `-p 3306:3306` sagt das er den Port des MySQL-Servers auf den lokalen Port `3306` auf dem Host-Computer durchleiten soll.

       docker run -t -i --name mysql-server --volumes-from mysql-data -p 3306:3306 32bit/ubuntu:14.04 /bin/bash

In der Bash-Shell installieren wir nun den MySQL-Server und alles wird eingerichtet. Ist dies fertig, detached man den Container mit dem Tasterturkürzel `CTRL-p CTRL-q`. Der Container sollte nun trotzdem weiterlaufen. Dies kann man sich mit `docker ps` anschauen. Um alle Änderungen zu speichern committed man die Änderungen mit:

	docker commit 72 mysql-server

Die `72` ist der Anfang des Hashes mit dem unser Container identifiziert wird. Nun haben wir ein Image mit dem Namen `mysql-server`. Wir starten nun alles komplett mit folgendem Befehl:

	docker run -d --name mysql-server --volumes-from mysql-data -p 3306:3306 mysql-server /usr/bin/mysqld_safe

Dies startet den Container im Daemon-Mode mit dem Namen `mysql-server`, den Namen für den Container und nicht für das Image, mit dem Volumes von unserem Data-Container mit dem Namen `mysql-data`, den Port `3306` gemappt auf `3306` am Host, und von dem Image `mysql-server`. Es wird der Befehl `/usr/bin/mysqld_safe` gestartet. Läuft alles können wir später den Container starten mit dem Befehl

	docker start mysql-server

Das wars eigentlich. Nun sollte man normal connecten können.

	mysql -uroot -p -h127.0.0.1

Ich hoffe ich habe alles zusammen bekommen. War ein ganz schöner Ritt und sehr Braintwisting am Anfang für mich.
