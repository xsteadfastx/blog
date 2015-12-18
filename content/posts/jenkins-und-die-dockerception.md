Title: Jenkins und die Dockerception
Date: 2015-12-18 14:09
Slug: jenkins-und-die-dockerception
Tags: jenkins, docker, linux

Nach meinen ersten Experimenten mit Jenkins und Docker geht es nun wieder einen Schritt weiter. Mein Jenkins läuft im Docker-Container hinter einem NGINX im Docker-Container. Was könnte also noch eine Steigerung sein? Noch schöner wäre es wenn die Tests bzw Builds in eigenen Containern laufen, die dann nach dem Run wieder in sich zusammen fallen. Ich versuche mal alles zusammen zuschreiben.

Docker in Docker
----------------

Der beste Weg ist es den Docker-Socket als Volume an den Container durchzureichen. Hier der [docker-compose](https://docs.docker.com/compose/)-Eintrag:

```
jenkins:
  container_name: jenkins
  build: ./jenkins/
  volumes:
    - "/srv/www/jenkins:/var/jenkins_home"
    - "/usr/bin/docker:/bin/docker"
    - "/usr/lib/x86_64-linux-gnu/libapparmor.so.1.1.0:/usr/lib/x86_64-linux-gnu/libapparmor.so.1"
    - "/var/run/docker.sock:/var/run/docker.sock"
  ports:
    - "8080:8080"
    - "50000:50000"
```

Wir müssen nicht nur den Socket durchreichen, sondern auch das Docker-Binary und eine Library (war in diesem Fall nötig). Sonst nichts besonderes hier. Die Ports sind einmal für die Jenkins Weboberfläche und einmal für die Kommunikation mit den Slaves die sich im Netz befinden. In meinem Fall ein Windows Build Slave.

Docker in Jenkins
-----------------

Ich benutze das offizielle [Jenkins Docker Image](https://hub.docker.com/_/jenkins/) mit ein paar Anpassungen. Das Dockerfile sieht wie folgt aus:

```
FROM jenkins

USER root

RUN apt-get update \
 && apt-get install -y \
    rsync \
 && rm -rf /var/lib/apt/lists/*

RUN addgroup --gid 116 docker \
 && usermod -a -G docker jenkins

USER jenkins
```

Ich installiere ein rsync und füge den Benutzer `jenkins` der `docker`-Gruppe hinzu damit der die Container starten, beenden und löschen kann.

Jenkins hat viele Plugins. Diese wiederum haben kaum bis garkeine Dokumentation oder klaffende Lücken in ihr. Also habe ich erstmal, ziemlich naiv, das [Docker Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin) installiert. Jenkins braucht erstmal eine Connection zu Docker. Dazu gehen wie in die Jenkins System Konfiguration in die `Cloud` Sektion. Neben einem Namen sollten wir auch die `Docker URL` eintragen. Die kann auch ein Socket sein. In diesem Fall `unix:///var/run/docker.sock`. Nun klappt die Kommunikation.

tox-jenkins-slave
-----------------

Nun brauchen wir ein Docker-Image das als Jenkins-Slave taugt. Ich habe mich ganz an dem Image von [evarga](https://hub.docker.com/r/evarga/jenkins-slave/) orientiert. [Mein Image](https://hub.docker.com/r/xsteadfastx/tox-jenkins-slave/) beinhaltet ein paar Änderungen. Zum Beispiel installiere ich nicht das gesammte JDK, sondern nur ein Headless-JRE. Sonst installiert er mir schön diverse X-Libraries. Die braucht man nicht um den Jenkins-Slave-Client auszuführen. Ich bin riesen [tox](https://tox.readthedocs.org)-Fan. Ein Tool um Tests in diversen Python Versionen auszuführen. Alles getrennt durch Virtualenv's. Dazu braucht tox aber auch die Python Versionen installiert. Dies funktioniert dank dem PPA von [fkrull](https://launchpad.net/~fkrull/+archive/ubuntu/deadsnakes) ganz wunderbar. Zum Schluß installiere ich tox selber und fertig ist das Image. Ach ja, ein `openssh-server` und `git` wird auch noch gebraucht. Hier das Dockerfile:

```
FROM ubuntu:trusty

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys DB82666C \
 && gpg --export DB82666C | apt-key add -

RUN echo deb http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu trusty main >> /etc/apt/sources.list \
 && echo deb-src http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu trusty main >> /etc/apt/sources.list

RUN apt-get update \
 && apt-get install -y \
    git \
    openssh-server \
    openjdk-7-jre-headless \
    python-pip \
    python2.3 \
    python2.4 \
    python2.5 \
    python2.6 \
    python3.1 \
    python3.2 \
    python3.3 \
    python3.4 \
    python3.5 \
 && rm -rf /var/lib/apt/lists/*

RUN pip install tox

RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd \
 && mkdir -p /var/run/sshd

RUN adduser --quiet jenkins \
 && echo "jenkins:jenkins" | chpasswd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

Es wird ein `jenkins` Benutzer mit dem Password `jenkins` angelegt. Wenn sich jemand daran stört soll er sich das Image selber bauen und dies verändern.

Um es zum Einsatz zu bringen müssen wir unter `Configure System` -> `Cloud` -> `Docker` -> `Add Docker Template` folgendes einstellen:

1. **Docker Image**: `xsteadfastx/tox-jenkins-slave`
2. **Remote Filing System Root**: `/home/jenkins`
3. **Labels**: `tox-jenkins-slave`
4. **Launch method**: `Docker SSH computer launcher`
  * **Credentials**: Add a new one with username `jenkins` and password `jenkins`
5. **Remote FS Root Mapping**: `/home/jenkins`
6. **Remove volumes**: `True`

Mir war nicht klar das das Label ausschlaggebend ist um den Job auch wirklich auf den passenden Container laufen zu lassen. Ohne Label kann dieser nicht getriggert werden.

Nun können wir im Job den Container einsetzen:

1. **Docker Container**: `True`
2. **Restrict where this project can be run**: `True`
  * **Label Expression**: `tox-jenkins-slave`

Sachen mit denen ich noch so gekämpft habe
------------------------------------------

Aus irgendeinem Grund hatte ich riesige Probleme mit den Locales in dem Container. Einige Tests haben Vergleichsdaten in Textfiles gespeichert. Falsche Locales haben die Tests gebrochen. Das Absurde... egal was ich tat, es half einfach nichts. `LANG` setzen in der `.bashrc` oder in `/etc/profile` wurde vollständig ignoriert. Startete ich den Container manuell und loggte mich per SSH ein, kein Problem, die Tests liefen durch. Der Slave gestartet von Jenkins, völlige Ingoranz meiner Config. Also musste ich es direkt in das Python Job Script packen:

```
import os
import tox

os .environ['LANG'] = 'C.UTF-8'
os.chdir(os.environ['WORKSPACE'])

tox.cmdline()
```

Ich setze die Environment-Variabel direkt im Script, gehe in den Jenkins-Workspace und führe `tox` aus. Ein Umweg, aber es funktioniert.

Schenkt den PyPI-Servern eine Auszeit
-------------------------------------

Noch eine Kleinigkeit: Da die Abhängigkeiten für die Tests bei jedem Durchlauf neu heruntergeladen werden lohnt sich der Einsatz von [devpi](http://doc.devpi.net/). Der kann sehr viel mehr, wird aber von mir als einfacher PyPI-Mirror missbraucht. Ich habe dafür auch ein kleines [Image](https://hub.docker.com/r/xsteadfastx/devpi/). Läuft der Container sieht mein Jenkins Job kompletto so aus:

```
import os
import tox

os.environ['LANG'] = 'C.UTF-8'

os.makedirs('/home/jenkins/.config/pip')
with open('/home/jenkins/.config/pip/pip.conf', 'w') as f:
  f.write('[install]\ntrusted-host = 192.168.1.8')

os.environ['PIP_INDEX_URL'] = 'http://192.168.1.8:3141/root/pypi/+simple/'

os.chdir(os.environ['WORKSPACE'])

tox.cmdline(['-e py33,py34,py35'])
```

Von nun an wird der Mirror benutzt.

{% giphy hDLrS6Z0oO33a %}
