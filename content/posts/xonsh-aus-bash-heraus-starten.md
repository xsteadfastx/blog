---
title: xonsh aus Bash heraus starten
slug: xonsh-aus-bash-heraus-starten
tags:
- xonsh
- python
- linux
date: "2016-07-29T15:39:00+02:00"
author: marvin
draft: false
---
Noch ein kleiner Nachtrag zu dem [Artikel]({{< ref "/posts/meine-neue-shell-xonsh.md" >}}) von gestern. Heute wollte ich mal wieder in meiner Blogging Vagrant Docker Box alles auf den neusten stand bringen. Ich benutze dazu `vagrant provision`. Dies startet das Provisioning, also holt meine neuen Config-Files. installiert neue Software usw. Ansible benutzt SSH um auf die Vagrant Box zuzugreifen und dies war auf einmal ein Problem. Ansible lief sofort an die Wand.

    /bin/sh: sudo -H -S -n -u root /bin/sh -c 'echo BECOME-SUCCESS-mtobhjchhszgqaaixzbsbsolwbuprmhn; LANG=de_DE.UTF-7 LC_ALL=de_DE.UTF-8 LC_MESSAGES=de_DE.UTF-8 /usr/bin/python /home/vagrant/.ansible/tmp/ansible-tmp-1469778394.25-104576843898387/apk; rm -rf \"/home/vagrant/.ansible/tmp/ansible-tmp-1469778394.25-104576843898387/\" > /dev/null 2>&1' && sleep 0: not found\r\n

Loggte ich mich ein und führe das Ansible Playbook manuell aus, kein Problem. Ich hatte xonsh als Login Shell eingerichtet und da läuft etwas schief. SSH ruft den Befehl per `exec` auf und da hat xonsh noch ein paar Probleme. Es gibt den Shell Befehl `exec` und die Python-Funktion `exec`. Diese sind schwierig zu unterscheiden und schon läuft es schief. Es wird an einem Fix gearbeitet. Der soll auch in den nächsten Tagen released werden. Bis dahin habe ich mich dazu entschieden meine Login-Shell wieder auf Bash umzustellen und daraus dann xonsh zu starten.

<del>Dazu benutze ich das File `~/.profile`. Dies ist dafür da Sachen beim Login auszuführen. Aber nur wenn es `~/.bash_profile` und `~/bash_login` nicht gibt. Ich erweitere also `~/.profile`.</del>

    [ -f /usr/local/bin/xonsh ] && exec /usr/local/bin/xonsh

<del>Wenn es `/usr/local/bin/xonsh` gibt dann führe es aus.</del>

Ich nahm an das es so funktionieren würde. Falsch gedacht. Es gab einige Probleme. Das schwerwiegendste war das LightDM mich nicht mehr einloggen wollte. Es liest beim einloggen die `~/.profile` und der `exec` Befehl behindert das ausführen von i3. Das starten von xonsh aus .profile heraus erschien mir als ein guter Weg. Aber sind wir mal ehrlich: Das ich xonsh nicht per `chsh` setzen kann, endet wohl oder übel in heftigstes, unsauberes gefrickel. Was macht man sonst an einem Samstag Vormittag? Nun kam ich zu folgender Lösung: Ich starte xonsh aus der `~/.bashrc` mit:

    [ -f /usr/local/bin/xonsh ] && exec /usr/local/bin/xonsh

Überraschung: die wird nicht immer geladen. SSH auf eine Alpine Linux Box warf mich in eine bash Shell. Also sollte man sich eine `~/.bash_profile` anlegen mit folgenden Inhalt:

    if [ -f ~/.bashrc ]; then
      . ~/.bashrc
    fi

Nun geht erstmal wieder alles. Ein Workaround... aber was solls? Ich warte auf das nächste Krachen. Aber am meisten freue ich mich auf den Fix.