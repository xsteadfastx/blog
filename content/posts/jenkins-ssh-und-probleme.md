---
title: Jenkins, ssh und Probleme
slug: jenkins-ssh-und-probleme
tags:
- jenkins
- ssh
date: "2015-01-14T12:30:00+01:00"
author: marvin
draft: false
---
Mein im vergangenes Post beschriebens Problem war dann doch nicht so einfach zu lösen. Nun ein neuer Ansatz: Den Dump einfach per Rsync ziehen. Also schön ssh-Keys für den Jenkins-User angelegt und gehofft:

	jenkins@box:~$ ssh userfoo@hostname
	Host key verification failed.

Ah ja. Makes sense. Irgendwie war der User nicht in der Lage das `known_hosts`-File anzulegen. Habe wirklich viel dran rumprobiert bis ich auf den Workaround kam:

Man loggt sich auf dem Jenkins-Server und auf der Bash ein mit

	sudo su jenkins -s /bin/bash

Dann einfach mal ein

	jenkins@box:~$ ssh userfoo@hostname

Und dann legt er auch `known_hosts` an und der Job läuft auf einmal im Jenkins. Was auch immer...