---
title: Jenkins, Docker und Ansible
slug: jenkins-docker-und-ansible
tags:
- jenkins
- docker
- ansible
date: "2015-05-07T14:06:00+02:00"
author: marvin
draft: false
---

Und ab in die Docker Hölle. Irgendwie scheint mir Docker nicht zu liegen. Es fängt schon damit an das mir noch nicht so ganz bewusst ist wieso man nicht einfach den Container schön macht und ihn dann immer wieder mit `docker start mein-toller-container` startet. Ich glaube es geht darum alles so weit wie möglich unabhängig zu machen. So mehr ich es benutze um so mehr wird mir langsam klar wie ich es "richtig" benutzen kann. Es scheint aber noch ein sehr langer und schmerzhafter Weg zu werden.

Da ich in letzter Zeit ein wenig mit [ansible](http://www.ansible.com/) rumgespielt habe, dachte ich ob dies ein Weg wäre alles für mich zu vereinfachen. Eine andere Alternative wäre [Docker Compose](https://docs.docker.com/compose/) gewesen. Es geht immer darum seine Container in einem YAML-File zu definieren und anstatt einer Batterie an Kommandos einzugeben, einfach den Composer oder halt Ansible anzuschmeißen. Docker kann schließlich schon ziemlich komplex werden wenn man [Data-Container](https://docs.docker.com/userguide/dockervolumes/) benutzt und auch noch mehrere Container miteinander [verlinkt](https://docs.docker.com/userguide/dockerlinks/). Ansible nimmt einem dabei nicht nur das Orchestrieren mit Docker ab, es kümmert sich auch gleich noch um das gesammte Setup.

Ich habe mir mal ein praktisches Beispiel genommen. Ich habe ja auf meinem Raspi ein [Jenkins](https://jenkins-ci.org/) laufen. Nicht gerade ein mächtiges Arbeitstier. Also wollte ich Jenkins schon seit einer Weile umziehen und dabei den Server nicht voll müllen. Schließlich braucht Jenkins für meine Tests auch Test-Datenbank usw. Diese sollten sich am besten nicht mit dem Host-System mischen. Dies ist das Ansible-Playbook was ich dafür genutzt habe. Ich versuche die Schritte durch die Kommentare zu erläutern. Das ganze gibt es auch als Repo auf [GitHub](https://github.com/xsteadfastx/jenkins_docker_ansible).


```
---
# In diesem Fall führe ich alles lokal aus. Dies funktioniert natürlich auch
# perfekt remote.
- hosts: localhost

  # Eine Ubuntu-Box hier. Also wäre sudo nicht schlecht.
  sudo: yes

  vars:
    # Die user-Variabel benutze ich vor allem um meine Images zu benennen.
    - user: xsteadfastx

    # Es wird ein lokales temp-Verzeichnis definiert. Dies wird gebraucht
    # um die Docker Images zu bauen.
    - temp_docker_build_dir: /tmp/docker-jenkins

    # Das offizielle MySQL Image braucht ein definiertes root-Password um
    # zu bauen.
    - mysql_root_password: nicepassword

  tasks:

    # Wir adden den Docker GPG-Key damit wir die offiziellen Pakete ziehen
    # können. Ich habe die ID aus dem Install-Script rausgepoppelt.
    # Keine Garantie ob er in Zukunft auch stimmt.
    - name: APT | add docker repo key
      apt_key: keyserver=hkp://p80.pool.sks-keyservers.net:80
               id=36A1D7869245C8950F966E92D8576A8BA88D21E9
               state=present

    # Wir adden das offizielle Docker Repo für frische Versionen.
    - name: APT | add docker repo
      apt_repository: repo="deb https://get.docker.com/ubuntu docker main"
                      update_cache=yes
                      state=present

    # Docker installieren.
    - name: APT | install docker
      apt: name=lxc-docker
           update_cache=yes
           cache_valid_time=600
           state=present

    # Auf dem Docker-Host benötigt Ansible Python-Bindings. Das Problem mit
    # mit den offiziellen "python-docker" debs: Sie waren schlicht und einfach
    # zu alt. Also müssen wir es von PyPi installieren. Eigentlich nicht die
    # tolle Art... aber ich mache mal eine Ausnahme.
    - name: PIP | install docker-py
      pip: name=docker-py
           version=1.1.0

    # Es soll ein Temp-Verzeichnis zum bauen des jenkins-data Images
    # angelegt werden.
    - name: DIR | create jenkins-data docker build directory
      file: path="{{ temp_docker_build_dir }}/jenkins-data"
            state=directory

    # Kopiere das Dockerfile in des temporäre Build-Verzeichnis
    - name: COPY | transfer jenkins-data Dockerfile
      copy: src=files/Dockerfile-jenkins-data
            dest="{{ temp_docker_build_dir }}/jenkins-data/Dockerfile"

    # Endlich kann es losgehen... und wir können das Image bauen.
    - name: DOCKER | build jenkins data image
      docker_image: path="{{ temp_docker_build_dir }}/jenkins-data"
                    name="{{ user }}/jenkins-data"
                    state=present

    # Das gleiche machen wir jetzt für unser leicht angepasstes Dockerfile.
    - name: DIR | create jenkins docker build directory
      file: path="{{ temp_docker_build_dir }}/jenkins"
            state=directory

    - name: COPY | transfer jenkins Dockerfile
      copy: src=files/Dockerfile-jenkins
            dest="{{ temp_docker_build_dir }}/jenkins/Dockerfile"

    - name: DOCKER | build jenkins image
      docker_image: path="{{ temp_docker_build_dir }}/jenkins"
                    name="{{ user }}/jenkins"
                    state=present

    # Nun löschen wir das temporäre Verzeichnis.
    - name: RM | remove temp docker build directory
      file: path="{{ temp_docker_build_dir }}"
            state=absent

    # Das interessante an data-only Volumes ist, dass sie nicht gestartet
    # werden müssen um benutzt zu werden. Sie sind nur dazu da um von anderen
    # Containern genutzt zu werden. Es werden Volumes definiert die wir dann
    # benutzen zu können. Auch wenn der Jenkins Container gelöscht und wieder
    # neugestartet wird... benutzt man diesen Data-Container bleiben die Daten
    # in "/var/jenkins_home" bestehen.
    - name: DOCKER | jenkins data volume
      docker:
        name: jenkins-data
        image: "{{ user }}/jenkins-data"
        state: present
        volumes:
          - /var/jenkins_home

    # Das gleiche machen wir für den mysql-data Container.
    - name: DOCKER | mysql data volume
      docker:
        name: mysql-data
        image: busybox
        state: present
        volumes:
          - /var/lib/mysql

    # Nun starten wir den mysql Container. Wir benutzen das offizielle
    # MySQL-Image. Der state "reloaded" bedeutet, dass wenn sie die Config
    # ändert... dann wird der Container entfernt und neu erstellt.
    # Wichtig ist hier das "volumes_from". Hier geben wir den Container an
    # von dem die definierten Volumes benutzt werden sollen. Also werden sie
    # in einem eigenes dafür angelegten Container gespeichert.
    # Kapselung und so. Mit "env" können wir auch noch diverese
    # Environment dem Container mitgeben. In diesem Fall ein Passwort für den
    # root-User für den Server. Diese Variabel wird gebraucht damit der
    # erstellte Container auch gestartet werden kann.
    - name: DOCKER | mysql container
      docker:
        name: mysql
        image: mysql:5.5
        state: reloaded
        pull: always
        volumes_from:
          - mysql-data
        env:
          MYSQL_ROOT_PASSWORD: "{{ mysql_root_password }}"

    # now finally the jenkins container. it links to the mysql container
    # because i need some mysql for some tests im running in jenkins.
    # and with the link i can easily use the environment variables in jenkins.
    # i bind the jenkins port only to localhost port 9090. i use nginx for
    # proxying. in "volumes" i define my host directory in which my git repos
    # are. so jenkins think its all in a local directory.
    # and "/var/jenkings_home" is stored in the "jenkins-data" container.
    # voila.

    # Hier ist nun das Herzstück. Hier kommt alles zusammen. Wir erstellen
    # den Jenkins Container und starten ihn. Wir benutzen als Basis unser
    # Jenkins Image. Mit "links" können wir mehrere laufende Container
    # miteinander verbinden. Diese sind dann untereinander über ein virtualles
    # Netz verbunden. Gleichzeitig stellt Docker dann Environment-Variables
    # zu verfügung. Diese können wir ganz prima im System nutzen. In diesem
    # Beispiel brauche ich für Tests in Jenkins ein paar MySQL-Datenbanken.
    # So ist der MySQL-Container im Jenkins-Container sichtbar und vor allem
    # benutzbar. Mit "ports" können wir bestimmte Ports nach Aussen mappen.
    # In diesem Fall mappe ich den standard Jenkins Port "8080" auf localhost
    # Port "9090". Perfekt um ihn per NGINX von Aussen zugänglich zu machen.
    # Mit "volumes" definieren wir lokale Verzeichnisse die an einer
    # bestimmten Stelle im Container zu verfügung gestellt werden. In diesem
    # Fall den lokalen Ordner mit den Git-Repos "/srv/git" in das
    # Container-Filesystem unter "/data". Also kein gefummel mit SSH-Keys
    # um Git im Container zu benutzen. Als letztes "volumes_from".
    # Damit können wir die Volumes aus einem anderen Container, in diesem Fall
    # des data-only Containers "jenkins-data", benutzen. Diese Daten würden
    # so den Tot des Jenkins Container überleben. Genau das was wir wollen.
    - name: DOCKER | jenkins container
      docker:
        name: jenkins
        image: "{{ user }}/jenkins"
        state: reloaded
        links:
          - "mysql:mysql"
        ports:
          - "127.0.0.1:9090:8080"
        volumes:
          - "/srv/git:/data"
        volumes_from:
          - jenkins-data
```


Hier das jenkins-data Dockerfile:

```
FROM busybox

RUN mkdir -p /var/jenkins_home \
  && chown -R default /var/jenkins_home

VOLUME /var/jenkins_home

CMD ["true"]
```


Und hier mein Jenkins Dockerfile. Ich benutze eigentlich das Offizielle noch mit ein paar extra Sachen die ich installiere. Dies sind auch spezielle Packages für meine Tests. Also Python-Kram.

```
FROM jenkins

USER root

RUN apt-get update && apt-get install -y python-dev python-setuptools python-virtualenv python-pip libjpeg-dev ansible mysql-client && rm -rf /var/lib/apt/lists/* && pip install tox
```

Also schießen wir mal los:

```
ansible-playbooks -i hosts site.yml -c local --ask-become-passansible-playbooks -i hosts site.yml -c local --ask-become-pass
```

Na mal schauen ob irgendwann der Zeitpunkt kommt an dem ich Docker besser verstehe. Ich verlinke hier nochmal den Docker Beitrag von Andrew T. Baker von der PyCon 2015.

{{< youtube GVVtR_hrdKI >}}